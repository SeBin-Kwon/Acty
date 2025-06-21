//
//  DetailView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import SwiftUI
import iamport_ios
import WebKit

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @StateObject var paymentViewModel: PaymentViewModel
    @State private var timeList = [ReservationTime]()
    @State private var participantCount = 1
    @State private var selectedDate = ""
    @State private var selectedTime = ("", "")
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    private var totalPrice: Int {
        participantCount * (viewModel.output.activityDetail?.price.final ?? 0)
    }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    let id: String
    private let userCode = "imp14511373"
    
    var body: some View {
        ScrollView {
            HStack {
                Text(viewModel.output.activityDetail?.title ?? "없음")
                    .font(.paperLogy(.title1))
                Spacer()
            }
            .padding(20)
            HStack {
                Text("액티비티 예약설정")
                    .font(.pretendard(.body2(.bold)))
                Spacer()
            }
            .padding(20)
            PersonCountView(count: $participantCount, minCount: 1, maxCount: viewModel.output.activityDetail?.restrictions.maxParticipants ?? 1)
                .padding(20)
            reservationSection
            paymentButton
            Text("\(totalPrice)원")
        }
        .onAppear {
            viewModel.input.onAppear.send(id)
            paymentViewModel.input.totalPrice = viewModel.output.activityDetail?.price.final ?? 0
        }
        .onReceive(paymentViewModel.output.paymentFailed) { error in
            alertTitle = "결제 실패"
            alertMessage = error
            showingAlert = true
        }
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(isPresented: $paymentViewModel.output.showingPaymentSheet) {
            
            if let payment = paymentViewModel.output.payment {
                IamportPaymentWebView(
                    payment: payment,
                    userCode: userCode,
                    onPaymentResult: { response in
                        paymentViewModel.input.paymentCompleted.send(response)
                    }
                )
            }
            
        }
    }
}

extension DetailView {
    
    private var paymentButton: some View {
        Text("결제하기")
            .font(.pretendard(.title(.bold)))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(selectedTime.1 != "" ? .deepBlue : .gray60)
            .clipShape(.rect(cornerRadius: 10))
            .wrapToButton {
                print("결제")
                paymentViewModel.input.activityId = id
                paymentViewModel.input.selectedDate = selectedDate
                paymentViewModel.input.selectedTime = selectedTime
                paymentViewModel.input.participantCount = participantCount
                paymentViewModel.input.totalPrice = totalPrice
                paymentViewModel.input.productName = viewModel.output.activityDetail?.title ?? ""
                paymentViewModel.input.paymentButtonTapped.send(())
            }
            .disabled(selectedTime == ("", ""))
    }
    
    private func timeButtonView(items: [ReservationTime]) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items, id: \.hashValue) { item in
                Button("\(item.time)") {
                    print("d")
                    withAnimation {
                        if selectedTime == (selectedDate, item.time) {
                            selectedTime = ("", "")
                        } else {
                            selectedTime = (selectedDate, item.time)
                        }
                        
                    }
                }
                .buttonStyle(.actySelected(selectedTime == (selectedDate, item.time), item.isReserved))
                .disabled(item.isReserved)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var reservationSection: some View {
        if let reservationList = viewModel.output.activityDetail?.reservationList {
            dateButtonRow(reservationList)
            timeButtonView(items: timeList)
        } else {
            Text("예약 불가")
        }
    }
    
    private func dateButtonRow(_ reservationList: [ReservationDate]) -> some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(reservationList, id: \.date) { item in
                        dateButton(item)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private func dateButton(_ item: ReservationDate) -> some View {
        let isAllReserved = item.times.allSatisfy(\.isReserved)
        
        return Button(item.date) {
            print("d")
            withAnimation {
                if selectedDate == item.date {
                    selectedDate = ""
                    timeList = []
                } else {
                    selectedDate = item.date
                    timeList = item.times
                }
                
            }
        }
        .buttonStyle(.actySelected(selectedDate == item.date, isAllReserved))
        .disabled(isAllReserved)
    }
}

//#Preview {
//    DetailView(
//           viewModel: DetailViewModel(
//               activityService: MockActivityService()
//           ),
//           id: "sample-activity-id"
//       )
//}
