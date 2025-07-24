//
//  ImagePreviewView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/24/25.
//

import SwiftUI

struct ImagePreviewView: View {
    let selectedImages: [Data]
    let onRemove: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, imageData in
                    ZStack(alignment: .topTrailing) {
                        // 이미지 미리보기
                        if let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // 삭제 버튼
                        Button {
                            onRemove(index)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray60)
                                .background(Color.white, in: Circle())
                        }
                        .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .frame(height: 100)
        .padding(.vertical, 8)
        .background(Color.white)
    }
}
