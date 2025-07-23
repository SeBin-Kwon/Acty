//
//  DetailView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import SwiftUI
import iamport_ios
import WebKit
import NukeUI

struct DetailView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: DetailViewModel
    @StateObject var paymentViewModel: PaymentViewModel
    @State private var timeList = [ReservationTime]()
    @State private var participantCount = 1
    @State private var selectedDate = ""
    @State private var selectedTime = ("", "")
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var currentImageIndex = 0
    
    private var totalPrice: Int {
        participantCount * (viewModel.output.activityDetail?.finalPriceInKRW ?? 0)
    }
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    let id: String
    private let userCode = "imp14511373"
    private var imageUrls: [String] {
        guard let detail = viewModel.output.activityDetail else { return [] }
        return detail.thumbnails
            .filter { thumbnail in
                let lowercased = thumbnail.lowercased()
                return lowercased.hasSuffix(".jpg") ||
                lowercased.hasSuffix(".jpeg") ||
                lowercased.hasSuffix(".png") ||
                lowercased.hasSuffix(".webp")
            }
            .map { BASE_URL + $0 }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    backgroundImageView
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            imageIndicators
                                .padding(.trailing, 20)
                                .padding(.bottom, 50)
                        }
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.5)
                contentHeader
                contentBody
            }
        }
        .ignoresSafeArea(edges: .top)
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    navigationRouter.navigateBack(in: .main)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 50 && abs(value.translation.height) < 50 {
                        navigationRouter.navigateBack(in: .main)
                    }
                }
        )
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
    
    private var backgroundImageView: some View {
        TabView(selection: $currentImageIndex) {
            if imageUrls.isEmpty {
                // 이미지가 아예 없을 때 기본 배경
                Rectangle()
                    .fill(.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .tag(0)
            } else {
                ForEach(0..<imageUrls.count, id: \.self) { index in
                    LazyImage(url: URL(string: imageUrls[index])) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.accent)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        }
                    }
                    .tag(index)
                }
            }
        }
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            // 그라데이션 오버레이
            LinearGradient(
                colors: [
                    Color.clear,
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.3),
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var imageIndicators: some View {
        VStack(spacing: 8) {
            ForEach(0..<min(imageUrls.count, 5), id: \.self) { index in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentImageIndex = index
                    }
                } label: {
                    LazyImage(url: URL(string: imageUrls[index])) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            // 이미지 로딩 중이거나 없을 때 색상 표시
                            Rectangle()
                                .fill(.deepBlue)
                        }
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                currentImageIndex == index ? Color.white : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(currentImageIndex == index ? 1.1 : 1.0)
                }
            }
            
            if imageUrls.isEmpty {
                ForEach(0..<3, id: \.self) { index in
                    Rectangle()
                        .fill(.deepBlue)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    private var contentHeader: some View {
        VStack(spacing: 16) {
            HStack(alignment: .bottom) {
                Text(viewModel.output.activityDetail?.title ?? "")
                    .font(.paperLogy(.title1))
                    .foregroundStyle(.gray90)
                Spacer()
                chatButton
            }
            
            countryText
            description
            HStack(spacing: 2) {
                Image("Buy")
                    .iconStyle(color: .gray45)
                Text("누적 구매 \(viewModel.output.activityDetail?.totalOrderCount ?? 0)회")
                    .font(.pretendard(.body3(.medium)))
                    .foregroundStyle(.gray45)
                Spacer()
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var countryText: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Text(viewModel.output.activityDetail?.country ?? "")
                Text(viewModel.output.activityDetail?.category ?? "")
            }
            .foregroundStyle(.gray60)
            HStack(spacing: 2) {
                Image("Point")
                    .iconStyle(color: .deepBlue)
                Text("\(viewModel.output.activityDetail?.pointReward ?? 0)P")
            }
            .foregroundStyle(.gray90)
            HStack(spacing: 2) {
                Image("Like_Fill")
                    .iconStyle(color: .rosy)
                Text("\(viewModel.output.activityDetail?.keepCount ?? 0)개")
            }
            .foregroundStyle(.gray90)
            Spacer()
        }
        .font(.pretendard(.body1(.bold)))
    }
    
    private var contentBody: some View {
        VStack(spacing: 20) {
            
            if let activityDetail = viewModel.output.activityDetail {
                ActivityDetailInfoView(activityDetail: activityDetail)
            }
            
            HStack {
                Text("액티비티 예약설정")
                    .font(.pretendard(.body1(.bold)))
                    .foregroundColor(.gray90)
                Spacer()
            }
            .padding(.horizontal, 20)
            
            PersonCountView(
                count: $participantCount,
                minCount: 1,
                maxCount: viewModel.output.activityDetail?.restrictions.maxParticipants ?? 1
            )
            .padding(.horizontal, 20)
            reservationSection

            HStack(spacing: 16) {
                Text("\(totalPrice)원")
                    .font(.paperLogy(.title1))
                    .foregroundColor(.gray90)
                Spacer()
                paymentButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
    }
    
    private var description: some View {
        HStack {
            Text(viewModel.output.activityDetail?.description ?? "")
                .font(.pretendard(.caption1(.regular)))
                .foregroundStyle(.gray60)
            Spacer()
        }
    }
    
    private var chatButton: some View {
        Image(systemName: "paperplane.fill")
            .font(.pretendard(.body1(.bold)))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(.accent)
            .clipShape(.rect(cornerRadius: 10))
            .wrapToButton {
                navigationRouter.navigate(to: .chat(userId: viewModel.userId), in: .main)
            }
    }
    
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
                .padding(.horizontal, 20)
            }
//            .padding(.bottom, 10)
        }
    }
    
    private func dateButton(_ item: ReservationDate) -> some View {
        let isAllReserved = item.times.allSatisfy(\.isReserved)
        
        return Button(formatDate(item.date)) {
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
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        
        if let date = formatter.date(from: dateString) {
            formatter.dateFormat = "M월 d일"
            return formatter.string(from: date)
        }
        
        return dateString
    }

}

#Preview {
    let diContainer = DIContainer.shared
    DetailView(
        viewModel: DetailViewModel(
            activityService: MockActivityService()
        ),
        paymentViewModel: diContainer.makePaymentViewModel(), id: "sample-activity-id"
    )
    .environmentObject(diContainer)
}
