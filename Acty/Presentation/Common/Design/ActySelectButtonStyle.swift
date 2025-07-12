//
//  ActySelectButtonStyle.swift
//  Acty
//
//  Created by Sebin Kwon on 6/4/25.
//

import SwiftUI

struct ActySelectButtonStyle: ButtonStyle {
    private let isSelected: Bool
    private let isDisabled: Bool
    
    init(isSelected: Bool, isDisabled: Bool = false) {
        self.isSelected = isSelected
        self.isDisabled = isDisabled
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let weight: Pretendard.Weight = isSelected ? .bold : .medium
        let textColor: Color = {
            if isDisabled {
                return .gray.opacity(0.5)
            } else {
                return isSelected ? .accent : .gray75
            }
        }()
        let backgroundColor: Color = {
            if isDisabled {
                return .gray.opacity(0.1)
            } else {
                return isSelected ? .accent.opacity(0.2) : .white
            }
        }()
        let strokeColor: Color = {
            if isDisabled {
                return .gray.opacity(0.2)
            } else {
                return isSelected ? .accent : Color.gray.opacity(0.3)
            }
        }()
        
        configuration.label
            .font(.pretendard(.body3(weight)))
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
    static func actySelected(_ isSelected: Bool, _ isDisabled: Bool) -> Self {
        ActySelectButtonStyle(isSelected: isSelected, isDisabled: isDisabled)
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
        
        Button("UnSelected + Disabled") {
                   
       }
        .buttonStyle(.actySelected(false, true))
       .disabled(true)
    }
}
