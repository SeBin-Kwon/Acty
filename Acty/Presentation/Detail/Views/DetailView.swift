//
//  DetailView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/11/25.
//

import SwiftUI

struct DetailView: View {
    @StateObject var viewModel: DetailViewModel
    @State private var selectedDate: String? = nil
    @State private var selectedTime: (String, String)? = nil
    @State private var timeList = [ReservationTime]()
    @State private var personCount = 1
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
    
    let id: String
    
    
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
            PersonCountView(count: $personCount, minCount: 1, maxCount: 8)
                .padding(20)    
            reservationSection
            paymentButton
        }
        .onAppear {
            viewModel.input.onAppear.send(id)
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
            .background(selectedTime != nil ? .deepBlue : .gray60)
            .clipShape(.rect(cornerRadius: 10))
            .wrapToButton {
                print("결제")
            }
            .disabled(selectedTime == nil)
    }

    private func timeButtonView(items: [ReservationTime]) -> some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items, id: \.hashValue) { item in
                Button("\(item.time)") {
                    print("d")
                    withAnimation {
                        if selectedTime ?? ("", "") == (selectedDate, item.time) {
                            selectedTime = nil
                        } else {
                            selectedTime = (selectedDate ?? "", item.time)
                        }
                        
                    }
                }
                .buttonStyle(.actySelected(selectedTime ?? ("", "") == (selectedDate, item.time), item.isReserved))
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
                    selectedDate = nil
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
