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

struct ActivityVideoView: View {
    let videoURL: String
    let activityId: String
    
    @State private var playerItem: VideoPlayerItem? = nil
    @State private var isInCenter: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 영상 플레이어
                if let playerItem = playerItem {
                    AVPlayerView(playerItem: playerItem)
                        .clipped()
                        .cornerRadius(12)
                        .background(Color.blue.opacity(0.3))
                } else {
                    // 로딩 중 플레이스홀더
                    loadingPlaceholder
                }
            }
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                pauseVideo()
            }
            .onChange(of: geometry.frame(in: .global)) { newFrame in
                checkIfInCenter(frame: newFrame)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupPlayer() {
        guard let url = URL(string: videoURL) else {
            print("❌ Invalid video URL: \(videoURL)")
            return
        }
        
        print("🎬 Setting up player for: \(videoURL)")
        let player = VideoPlayerManager.shared.getPlayer(for: activityId, url: url)
        self.playerItem = player
    }
    
    private func checkIfInCenter(frame: CGRect) {
        let screenBounds = UIScreen.main.bounds
        let screenCenter = CGPoint(x: screenBounds.midX, y: screenBounds.midY)
        
        // 영상의 중앙 부분이 화면 중앙과 가까운지 확인
        let videoCenterY = frame.midY
        let distanceFromCenter = abs(videoCenterY - screenCenter.y)
        
        // 화면 높이의 25% 이내에 있으면 "중앙"으로 간주
        let centerThreshold = screenBounds.height * 0.25
        let shouldBeInCenter = distanceFromCenter < centerThreshold && frame.intersects(screenBounds)
        
        if shouldBeInCenter != isInCenter {
            isInCenter = shouldBeInCenter
            
            if isInCenter {
                print("🎯 Video entered center: \(activityId)")
                playVideo()
            } else {
                print("🎯 Video left center: \(activityId)")
                pauseVideo()
            }
        }
    }
    
    private func playVideo() {
        print("🎬 playVideo() called for: \(activityId)")
        print("🎬 Current playing ID: \(VideoPlayerManager.shared.currentPlayingId ?? "nil")")
        
        // 다른 모든 영상 정지 후 현재 영상만 재생
        VideoPlayerManager.shared.setCurrentPlaying(activityId)
        
        // 확인: 실제로 설정되었는지
        print("🎬 After setCurrentPlaying: \(VideoPlayerManager.shared.currentPlayingId ?? "nil")")
    }
    
    private func pauseVideo() {
        if VideoPlayerManager.shared.currentPlayingId == activityId {
            print("🛑 Pausing current video: \(activityId)")
            VideoPlayerManager.shared.setPlayerVisibility(activityId, isVisible: false)
        } else {
            print("🤐 Skipping pause for non-current video: \(activityId)")
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
                .fill(Color.red.opacity(0.3))
            
            VStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("영상 URL 오류")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text(videoURL)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ActivityVideoView(
            videoURL: BASE_URL + "/data/activities/8290926-sd_640_360_30fps_1750835811684.mp4",
            activityId: "preview_activity_1"
        )
        .frame(height: 200)
        
        ActivityVideoView(
            videoURL: BASE_URL + "/data/activities/8290926-sd_640_360_30fps_1750835811684.mp4",
            activityId: "preview_activity_2"
        )
        .frame(height: 200)
    }
    .padding()
}
