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
            Image(systemName: "burst.fill")
                .font(.system(size: 50))
                .foregroundColor(.accent)
            
            Text("ACTY")
                .font(.paperLogy(.custom(.Black, CGFloat(40))))
                .foregroundColor(.accent)
        }
    }
}

#Preview {
    SplashView()
}
