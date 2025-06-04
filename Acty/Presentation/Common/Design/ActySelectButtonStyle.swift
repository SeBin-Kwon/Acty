//
//  ActySelectButtonStyle.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import SwiftUI

struct ActySelectButtonStyle: ButtonStyle {
    private let isSelected: Bool
    
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let weight: Pretendard.Weight = isSelected ? .bold : .medium
        let textColor: Color = isSelected ? .accent : .black
        let backgroundColor: Color = isSelected ? .accent.opacity(0.2) : .white
        
        configuration.label
            .font(.pretendard(.body2(weight)))
            .foregroundStyle(textColor)
            .padding(.horizontal, 17)
            .frame(height: 28)
            .background(backgroundColor)
            .overlay(
                Capsule()
                    .stroke(isSelected ? .accent : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.3), value: isSelected)
    }
}

extension ButtonStyle where Self == ActySelectButtonStyle {
    static func actySelected(_ isSelected: Bool) -> Self {
        ActySelectButtonStyle(isSelected: isSelected)
    }
}

#Preview {
    VStack {
        Button("Selected") {
            
        }
        .buttonStyle(.actySelected(true))
        
        Button("UnSelected") {
            
        }
        .buttonStyle(.actySelected(false))
    }
}
