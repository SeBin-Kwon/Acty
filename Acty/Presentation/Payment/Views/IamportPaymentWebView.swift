//
//  IamportPaymentWebView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/18/25.
//

import SwiftUI
import WebKit
import iamport_ios

struct IamportPaymentWebView: UIViewControllerRepresentable {
    let payment: IamportPayment
    let userCode: String
    let onPaymentResult: (IamportResponse?) -> Void
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let paymentVC = IamportPaymentWebViewController()
        paymentVC.payment = payment
        paymentVC.userCode = userCode
        paymentVC.onPaymentResult = onPaymentResult
        
        let navController = UINavigationController(rootViewController: paymentVC)
        navController.isNavigationBarHidden = true
        return navController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

class IamportPaymentWebViewController: UIViewController {
    var payment: IamportPayment?
    var userCode: String?
    var onPaymentResult: ((IamportResponse?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestPayment()
    }
    
    private func requestPayment() {
        guard let payment = payment,
              let userCode = userCode else {
            print("결제 정보가 없습니다.")
            return
        }
        
        print("=== 포트원 결제 요청 ===")
        print("userCode: \(userCode)")
        print("merchant_uid: \(payment.merchant_uid)")
        print("name: \(payment.name ?? "")")
        print("buyer_name: \(payment.buyer_name ?? "")")
        print("========================")
        
        let webView = WKWebView()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 포트원 결제 요청
        Iamport.shared.paymentWebView(
            webViewMode: webView,
            userCode: userCode,
            payment: payment
        ) { [weak self] iamportResponse in
            print("=== 포트원 결제 응답 ===")
            if let response = iamportResponse {
                print("success: \(response.success ?? false)")
                print("imp_uid: \(response.imp_uid ?? "")")
                print("merchant_uid: \(response.merchant_uid ?? "")")
                print("error_msg: \(response.error_msg ?? "")")
            } else {
                print("응답이 nil입니다.")
            }
            print("========================")
            
            DispatchQueue.main.async {
                self?.onPaymentResult?(iamportResponse)
            }
        }
    }
}
