//
//  IconStyleModifier.swift
//  Acty
//
//  Created by Sebin Kwon on 7/12/25.
//

import SwiftUI

extension Image {
    func iconStyle(width: CGFloat = 15, height: CGFloat = 15, color: Color = .white) -> some View {
        self
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .foregroundColor(color)
    }
}
