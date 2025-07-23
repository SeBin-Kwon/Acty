//
//  BannerSectionView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/23/25.
//

import SwiftUI

struct BannerSectionView: View {
    let banners: [Banner]
    @State private var currentBannerIndex = 0
    @State private var bannerTimer: Timer?
    @State private var selectedBannerURL: String? = nil
    @State private var showWebView: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            if !banners.isEmpty {
                TabView(selection: $currentBannerIndex) {
                    ForEach(Array(banners.enumerated()), id: \.offset) { index, banner in
                        BannerView(banner: banner) {
                            selectedBannerURL = banner.fullWebURL
                                showWebView = true
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 100)
                .onChange(of: currentBannerIndex) { _ in
                    restartBannerTimer()
                }
                .onAppear {
                    startBannerTimer()
                }
            }
        }
        .sheet(isPresented: $showWebView) {
            if let url = selectedBannerURL {
                BannerWebView(url: url)
            }
        }
    }
    // 배너 타이머 관리
    private func startBannerTimer() {
        guard !banners.isEmpty else { return }
        
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentBannerIndex = (currentBannerIndex + 1) % banners.count
            }
        }
    }
    
    private func stopBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    private func restartBannerTimer() {
        stopBannerTimer()
        startBannerTimer()
    }
}
