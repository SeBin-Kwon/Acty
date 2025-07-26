//
//  ActivityVideoView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/26/25.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - AVPlayerView (UIKit Wrapper)
struct AVPlayerView: UIViewRepresentable {
    let playerItem: VideoPlayerItem
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        // PlayerLayer를 View에 추가
        playerItem.playerLayer.frame = view.bounds
        view.layer.addSublayer(playerItem.playerLayer)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 레이어 프레임 업데이트
        DispatchQueue.main.async {
            playerItem.playerLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Activity Video View
struct ActivityVideoView: View {
    let videoURL: String
    let activityId: String
    
    @StateObject private var viewModel = ActivityVideoViewModel()
    @State private var isVisible: Bool = false
    
    private var fullVideoURL: URL? {
        URL(string: BASE_URL + videoURL)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let url = fullVideoURL {
                    // 영상 플레이어
                    if let playerItem = viewModel.playerItem {
                        AVPlayerView(playerItem: playerItem)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        // 로딩 중 플레이스홀더
                        loadingPlaceholder
                    }
                } else {
                    // URL 오류 플레이스홀더
                    errorPlaceholder
                }
            }
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                cleanup()
            }
            .onChange(of: geometry.frame(in: .global)) { newFrame in
                checkVisibility(frame: newFrame)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer() {
        guard let url = fullVideoURL else { return }
        viewModel.setupPlayer(id: activityId, url: url)
    }
    
    private func cleanup() {
        viewModel.cleanup()
        updateVisibility(false)
    }
    
    private func checkVisibility(frame: CGRect) {
        let screenBounds = UIScreen.main.bounds
        let visibleFrame = frame.intersection(screenBounds)
        
        // 영상의 50% 이상이 화면에 보이면 재생
        let visibilityThreshold: CGFloat = 0.5
        let visibleArea = visibleFrame.width * visibleFrame.height
        let totalArea = frame.width * frame.height
        
        let newVisibility = totalArea > 0 && (visibleArea / totalArea) >= visibilityThreshold
        
        if newVisibility != isVisible {
            isVisible = newVisibility
            updateVisibility(newVisibility)
        }
    }
    
    private func updateVisibility(_ visible: Bool) {
        VideoPlayerManager.shared.setPlayerVisibility(activityId, isVisible: visible)
    }
    
    // MARK: - Placeholder Views
    
    private var loadingPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
            
            ProgressView()
                .scaleEffect(0.8)
                .tint(.white)
        }
    }
    
    private var errorPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text("영상을 불러올 수 없습니다")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Activity Video ViewModel
class ActivityVideoViewModel: ObservableObject {
    @Published var playerItem: VideoPlayerItem? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func setupPlayer(id: String, url: URL) {
        // VideoPlayerManager에서 플레이어 가져오기
        let player = VideoPlayerManager.shared.getPlayer(for: id, url: url)
        
        DispatchQueue.main.async { [weak self] in
            self?.playerItem = player
        }
        
        // 플레이어 상태 관찰
        player.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink { isPlaying in
                // 필요시 UI 업데이트
                print("Video \(id) is \(isPlaying ? "playing" : "paused")")
            }
            .store(in: &cancellables)
    }
    
    func cleanup() {
        cancellables.removeAll()
        // Note: VideoPlayerManager가 플레이어 생명주기를 관리하므로 여기서는 정리하지 않음
    }
    
    deinit {
        cleanup()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ActivityVideoView(
            videoURL: "/data/activities/sample_video.mp4",
            activityId: "preview_activity_1"
        )
        .frame(height: 200)
        
        ActivityVideoView(
            videoURL: "/data/activities/sample_video2.mp4",
            activityId: "preview_activity_2"
        )
        .frame(height: 200)
    }
    .padding()
}
