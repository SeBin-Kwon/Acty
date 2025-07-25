//
//  ChatImageLayoutView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/24/25.
//

import SwiftUI
import NukeUI

struct ChatImageLayoutView: View {
    let imageUrls: [String]
    let isUploading: Bool
    let maxWidth: CGFloat = 200
    
    // 🔧 상태를 내부에서 관리
    @State private var showImageViewer = false
    @State private var selectedImageIndex = 0
    
    var body: some View {
        Group {
            switch imageUrls.count {
            case 1:
                singleImageLayout
            case 2:
                twoImagesLayout
            case 3:
                threeImagesLayout
            case 4:
                fourImagesLayout
            case 5:
                fiveImagesLayout
            default:
                EmptyView()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .fullScreenCover(isPresented: $showImageViewer) {
            ImageViewerView(
                imageUrls: imageUrls,
                initialIndex: selectedImageIndex,
                isPresented: $showImageViewer
            )
        }
    }
    
    // MARK: - 1개 이미지
    private var singleImageLayout: some View {
        imageView(for: imageUrls[0], imageIndex: 0, width: maxWidth, height: maxWidth * 0.75)
    }
    
    // MARK: - 2개 이미지
    private var twoImagesLayout: some View {
        HStack(spacing: 2) {
            ForEach(0..<2) { i in
                imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.6)
            }
        }
    }
    
    // MARK: - 3개 이미지
    private var threeImagesLayout: some View {
        HStack(spacing: 2) {
            imageView(for: imageUrls[0], imageIndex: 0, width: maxWidth/2 - 1, height: maxWidth * 0.8)
            
            VStack(spacing: 2) {
                ForEach(1..<3) { i in
                    imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.4 - 1)
                }
            }
        }
    }
    
    // MARK: - 4개 이미지
    private var fourImagesLayout: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(0..<2) { i in
                    imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.4)
                }
            }
            HStack(spacing: 2) {
                ForEach(2..<4) { i in
                    imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.4)
                }
            }
        }
    }
    
    // MARK: - 5개 이미지
    private var fiveImagesLayout: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(0..<2) { i in
                    imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.35)
                }
            }
            HStack(spacing: 2) {
                ForEach(2..<4) { i in
                    imageView(for: imageUrls[i], imageIndex: i, width: maxWidth/2 - 1, height: maxWidth * 0.35)
                }
            }
            imageView(for: imageUrls[4], imageIndex: 4, width: maxWidth, height: maxWidth * 0.3)
        }
    }
    
    // MARK: - 이미지뷰 생성 헬퍼
    private func imageView(for url: String, imageIndex: Int, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            if isUploading {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    )
            } else {
                LazyImage(url: URL(string: BASE_URL + url)) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if state.error != nil {
                        Rectangle()
                            .fill(Color.red.opacity(0.3))
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.white)
                            )
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            )
                    }
                }
                // 🔧 직접 탭 제스처 사용
                .onTapGesture {
                    print("🖼️ 이미지 탭됨 - 인덱스: \(imageIndex)")
                    selectedImageIndex = imageIndex
                    showImageViewer = true
                }
            }
        }
        .frame(width: width, height: height)
        .clipped()
    }
}
