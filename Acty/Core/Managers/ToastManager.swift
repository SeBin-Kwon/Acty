//
//  ToastManager.swift
//  Acty
//
//  Created by Sebin Kwon on 7/26/25.
//

import UIKit
import SwiftUI

final class ToastManager: ObservableObject {
   @Published var showToast = false
   @Published var toastMessage = ""
   @Published var isToastSuccess = true
   
   func showToast(message: String, isSuccess: Bool = true) {
       toastMessage = message
       isToastSuccess = isSuccess
       showToast = true
       
       showUIKitToast(message: message, isSuccess: isSuccess)
   }
   
   private func showUIKitToast(message: String, isSuccess: Bool) {
       DispatchQueue.main.async {
           guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                 let window = windowScene.windows.first else { return }
           
           // SwiftUI ToastView를 UIHostingController로 감싸기
           let toastView = ToastView(message: message, isSuccess: isSuccess)
           let hostingController = UIHostingController(rootView: toastView)
           hostingController.view.backgroundColor = .clear
           
           // Safe Area 고려해서 최종 위치 설정
           let safeAreaTop = window.safeAreaInsets.top
           let finalY = safeAreaTop + 20
           let startY = finalY - 80 // 시작 위치 (위쪽에서)
           
           // 시작 위치 설정 (위에서 시작, 투명)
           hostingController.view.frame = CGRect(
               x: 20,
               y: startY,
               width: window.frame.width - 40,
               height: 60
           )
           hostingController.view.alpha = 0
           
           window.addSubview(hostingController.view)
           
           // 나타나는 애니메이션 (위에서 아래로 + fade in)
           UIView.animate(withDuration: 0.4,
                        delay: 0,
                        usingSpringWithDamping: 0.8,
                        initialSpringVelocity: 0.5,
                        options: .curveEaseOut) {
               hostingController.view.frame.origin.y = finalY
               hostingController.view.alpha = 1.0
           }
           
           // 3초 후 사라지는 애니메이션 (아래에서 위로 + fade out)
           DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
               UIView.animate(withDuration: 0.3,
                            delay: 0,
                            options: .curveEaseIn,
                            animations: {
                   hostingController.view.frame.origin.y = startY // 위로 올라감
                   hostingController.view.alpha = 0
               }) { _ in
                   hostingController.view.removeFromSuperview()
               }
           }
       }
   }
}
