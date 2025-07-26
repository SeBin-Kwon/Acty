//
//  BannerWebView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/21/25.
//

import SwiftUI
import WebKit

struct BannerWebView: View {
    let url: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var toastManager: ToastManager
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("✕") {
                    dismiss()
                }
            }
            .padding()
            
            WebViewRepresentable(url: url, toastManager: toastManager)
        }
        .navigationBarHidden(true)
    }
}
