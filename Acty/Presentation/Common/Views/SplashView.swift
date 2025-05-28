//
//  SplashView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/28/25.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
            Text("Acty")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

#Preview {
    SplashView()
}
