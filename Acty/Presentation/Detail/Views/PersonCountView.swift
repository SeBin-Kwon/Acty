//
//  PersonCountView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import SwiftUI

struct PersonCountView: View {
    @Binding var count: Int
    let minCount: Int
    let maxCount: Int
    
    init(count: Binding<Int>, minCount: Int = 1, maxCount: Int = 10) {
        self._count = count
        self.minCount = minCount
        self.maxCount = maxCount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("인원 선택")
                    .font(.pretendard(.body2(.bold)))
                Spacer()
                Text("\(count)명")
                    .font(.pretendard(.body2(.medium)))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 0) {
                // 감소 버튼
                Button(action: decreaseCount) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(count <= minCount ? .gray.opacity(0.5) : .deepBlue)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .disabled(count <= minCount)
                
                // 인원수 표시
                Text("\(count)")
                    .font(.pretendard(.title(.bold)))
                    .foregroundColor(.black)
                    .frame(minWidth: 60)
                    .multilineTextAlignment(.center)
                
                // 증가 버튼
                Button(action: increaseCount) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(count >= maxCount ? .gray.opacity(0.5) : .deepBlue)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .disabled(count >= maxCount)
                
                Spacer()
            }
            
            // 제한 안내
            HStack {
                Text("최소 \(minCount)명, 최대 \(maxCount)명")
//                    .font(.pretendard(.caption(.regular)))
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func increaseCount() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if count < maxCount {
                count += 1
            }
        }
    }
    
    private func decreaseCount() {
        withAnimation(.easeInOut(duration: 0.2)) {
            if count > minCount {
                count -= 1
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        PersonCountView(count: .constant(2), minCount: 1, maxCount: 8)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
