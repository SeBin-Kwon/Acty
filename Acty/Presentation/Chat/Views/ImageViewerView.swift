//
//  ImageViewerView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/24/25.
//

import SwiftUI
import NukeUI

struct ImageViewerView: View {
    let imageUrls: [String]
    @State private var currentIndex: Int
    @Binding var isPresented: Bool
    
    init(imageUrls: [String], initialIndex: Int = 0, isPresented: Binding<Bool>) {
        self.imageUrls = imageUrls
        self._currentIndex = State(initialValue: initialIndex)
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentIndex) {
                ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                    ZoomableImageView(imageUrl: BASE_URL + url)
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack {
                HStack {
                    // 닫기 버튼
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.5), in: Circle())
                        .wrapToButton {
                            isPresented = false
                        }
                    
                    Spacer()
                    
                    // 이미지 카운터
                    Text("\(currentIndex + 1) / \(imageUrls.count)")
                        .font(.pretendard(.caption2(.regular)))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5), in: Capsule())
                }
                .padding()
                
                Spacer()
                
                if imageUrls.count > 1 {
                    HStack(spacing: 8) {
                        ForEach(0..<imageUrls.count, id: \.self) { index in
                            Circle()
                                .fill(currentIndex == index ? Color.white : Color.white.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
            Spacer()
        }
        .statusBarHidden()
    }
}

// MARK: - 줌 가능한 이미지뷰
struct ZoomableImageView: View {
    let imageUrl: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var isZoomed: Bool = false
    
    var body: some View {
        // ✅ 전체 화면을 차지하고 가운데 정렬
        ZStack {
            Color.clear
            
            LazyImage(url: URL(string: imageUrl)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .scaleEffect(scale)
                        .offset(offset)
                        .clipped()
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = lastScale * value
                                    scale = min(max(newScale, 0.5), 4.0)
                                    isZoomed = scale > 1.1
                                }
                                .onEnded { _ in
                                    lastScale = scale
                                    
                                    if scale < 1.0 {
                                        withAnimation(.spring()) {
                                            resetZoom()
                                        }
                                    }
                                }
                        )
                    // 🔧 드래그 제스처는 줌 상태일 때만 활성화
                        .gesture(
                            isZoomed ?
                            AnyGesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            ) : nil
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                if scale > 1.0 {
                                    resetZoom()
                                } else {
                                    scale = 2.0
                                    lastScale = 2.0
                                    isZoomed = true
                                }
                            }
                        }
                } else if state.error != nil {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        Text("이미지를 불러올 수 없습니다")
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ 에러 뷰도 가운데 정렬
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ 로딩 뷰도 가운데 정렬
                }
            }
        }
    }
    
    private func resetZoom() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
        isZoomed = false
    }
}
