//
//  VideoPlayerManager.swift
//  Acty
//
//  Created by Sebin Kwon on 7/26/25.
//

import UIKit
import Combine
import AVFoundation

class VideoPlayerManager: ObservableObject {
    static let shared = VideoPlayerManager()
    
    @Published private var players: [String: VideoPlayerItem] = [:]
    @Published var currentPlayingId: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            // 백그라운드에서도 다른 오디오와 함께 재생 가능하도록 설정
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowAirPlay]
            )
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    /// 새로운 영상 플레이어 생성 또는 기존 플레이어 반환
    func getPlayer(for id: String, url: URL) -> VideoPlayerItem {
        if let existingPlayer = players[id] {
            return existingPlayer
        }
        
        let newPlayer = VideoPlayerItem(id: id, url: url)
        players[id] = newPlayer
        
        return newPlayer
    }
    
    /// 특정 영상을 현재 재생 중인 영상으로 설정
    func setCurrentPlaying(_ id: String?) {
        // 이전 재생 중인 영상 정지
        if let currentId = currentPlayingId,
           let currentPlayer = players[currentId] {
            currentPlayer.setVisible(false)
        }
        
        // 새로운 영상 재생
        currentPlayingId = id
        if let newId = id,
           let newPlayer = players[newId] {
            newPlayer.setVisible(true)
        }
    }
    
    /// 영상이 화면에 보이는지 설정
    func setPlayerVisibility(_ id: String, isVisible: Bool) {
        guard let player = players[id] else { return }
        
        if isVisible {
            // 다른 영상들 정지하고 이 영상만 재생
            setCurrentPlaying(id)
        } else {
            player.setVisible(false)
            if currentPlayingId == id {
                currentPlayingId = nil
            }
        }
    }
    
    /// 모든 영상 정지
    func pauseAll() {
        players.values.forEach { $0.pause() }
        currentPlayingId = nil
    }
    
    /// 사용하지 않는 플레이어 제거 (메모리 최적화)
    func removePlayer(for id: String) {
        if let player = players[id] {
            player.pause()
            players.removeValue(forKey: id)
            
            if currentPlayingId == id {
                currentPlayingId = nil
            }
        }
    }
    
    /// 모든 플레이어 제거
    func removeAllPlayers() {
        players.values.forEach { $0.pause() }
        players.removeAll()
        currentPlayingId = nil
    }
    
    /// 메모리 정리 (앱이 백그라운드로 갈 때 등)
    func cleanup() {
        pauseAll()
        // 필요시 일부 플레이어 제거 (메모리 부족 시)
        if players.count > 10 {
            let sortedPlayers = players.sorted { $0.key < $1.key }
            let playersToRemove = sortedPlayers.prefix(players.count - 5)
            
            for (id, _) in playersToRemove {
                removePlayer(for: id)
            }
        }
    }
}

// MARK: - App Lifecycle Extension
extension VideoPlayerManager {
    func setupAppLifecycleObservers() {
        // 앱이 백그라운드로 갈 때
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.pauseAll()
            }
            .store(in: &cancellables)
        
        // 앱이 포그라운드로 올 때
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                // 현재 재생 중인 영상이 있다면 다시 재생
                if let currentId = self?.currentPlayingId,
                   let currentPlayer = self?.players[currentId],
                   currentPlayer.isVisible {
                    currentPlayer.play()
                }
            }
            .store(in: &cancellables)
    }
}

class VideoPlayerItem: ObservableObject {
    let id: String
    let player: AVPlayer
    let playerLayer: AVPlayerLayer
    @Published var isPlaying: Bool = false
    @Published var isVisible: Bool = false
    
    private var playerObserver: Any?
    private var cancellables = Set<AnyCancellable>()
    
    init(id: String, url: URL) {
        self.id = id
        
        let headers = [
            "SeSACKey": API_KEY,
            "Authorization": (try? DIContainer.shared.tokenService.getAccessToken()) ?? ""
        ]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey": headers])
        let playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        self.playerLayer = AVPlayerLayer(player: player)
        
        // 무음 설정
        player.isMuted = true
        
        // 플레이어 레이어 설정
        playerLayer.videoGravity = .resizeAspectFill
        
        setupPlayerObservers()
        setupLooping()
    }
    
    deinit {
        cleanup()
    }
    
    private func setupPlayerObservers() {
        // 플레이어 상태 관찰
        player.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                DispatchQueue.main.async {
                    self?.isPlaying = (status == .playing)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupLooping() {
        // 영상 끝나면 다시 재생 (무한 반복)
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
            .sink { [weak self] _ in
                self?.player.seek(to: .zero)
                if self?.isVisible == true {
                    self?.player.play()
                }
            }
            .store(in: &cancellables)
    }
    
    func play() {
        guard isVisible else { return }
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func setVisible(_ visible: Bool) {
        isVisible = visible
        if visible {
            play()
        } else {
            pause()
        }
    }
    
    private func cleanup() {
        pause()
        if let observer = playerObserver {
            player.removeTimeObserver(observer)
        }
        cancellables.removeAll()
    }
}
