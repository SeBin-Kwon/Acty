//
//  HomeView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import NukeUI

struct HomeView: View {
    
    @State private var selectedCountry: Country? = nil
    @State private var selectedCategory: Category? = nil
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                filterRow
                categoryFilterRow
                activityBanner
            }
            .padding(20)
        }
        .onAppear {
            viewModel.input.onAppear.send(())
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("SESAC ACTIVITY")
                    .font(.paperLogy(.caption1))
                    .foregroundStyle(.accent)
            }
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    print("bell")
                } label: {
                    Image(systemName: "bell")
                }
                
                Button {
                    print("gearshape")
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
    }
}


extension HomeView {
    
    private var activityBanner: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.output.activityList, id: \.id) { activity in
                    ActivityBannerView(activity: activity)
                }
            }
        }
    }
    
//    private func activityBannerCardView(_ activity: Activity) -> some View {
//        ZStack {
//            LazyImage(url: URL(string: activity.thumbnails.first!)) { state in
//                if let image = state.image {
//                    image
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                } else if state.error != nil {
//                    Rectangle()
//                        .fill(LinearGradient(
//                            colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)],
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        ))
//                } else {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.3))
//                        .overlay(
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        )
//                }
//            }
//            .frame(width: 300, height: 300)
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            Text(activity.title)
//        }
//    }
    
//    private func newActivityCard(_ activity: Activity) -> some View {
//        RoundedRectangle(cornerRadius: 24)
//            .fill(Color.gray.opacity(0.2))
//    }
    
    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Country.allCases, id: \.rawValue) { country in
                    countryFilterButton(country)
                }
            }
        }
    }
    
    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Category.allCases, id: \.rawValue) { category in
                    categoryFilterButton(category)
                }
            }
        }
    }
    
    private func countryFilterButton(_ country: Country) -> some View {
        HStack(spacing: 12) {
            
            Image(country.rawValue)
            Text(country.koreaName)
                
                .foregroundColor(selectedCountry == country ? .accent : .primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(selectedCountry == country ? .accent.opacity(0.2) : .white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selectedCountry == country ? .accent : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .clipShape(.rect(cornerRadius: 10))
        .wrapToButton {
            withAnimation {
                selectedCountry = country
            }
        }
    }
    
    private func categoryFilterButton(_ category: Category) -> some View {
        Text(category.koreaName)
            .wrapToButton {
                print("D")
            }
//            .buttonStyle(.actySelected(true))
    }
    
    
}

struct ActivityBannerView: View {
    let activity: Activity
    
    var body: some View {
        ZStack {
            // 배경 이미지 (Nuke 사용)
            LazyImage(url: URL(string: activity.mainThumbnail ?? "")) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if state.error != nil {
                    // 에러 시 기본 이미지
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                } else {
                    // 로딩 중
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
            }
            .frame(width: 350, height: 450)
            .clipped()
            
            // 오버레이 그라데이션
            LinearGradient(
                colors: [
                    Color.black.opacity(0.1),
                    Color.black.opacity(0.3),
                    Color.black.opacity(0.7)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 콘텐츠
            VStack(alignment: .leading, spacing: 12) {
                // 상단 카테고리 태그
                HStack {
                    Text(activity.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .background(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Spacer()
                    
                }
                
                Spacer()
                
                // 하단 콘텐츠
                VStack(alignment: .leading, spacing: 8) {
                    // 제목
                    Text(activity.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // 가격
                    HStack {
                        Image(systemName: "wonsign.circle.fill")
                            .foregroundColor(.white)
                            .font(.title3)
                        Text(String(activity.formattedFinalPrice))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // 설명
//                    Text(activity.description)
//                        .font(.body)
//                        .foregroundColor(.white.opacity(0.9))
//                        .lineLimit(3)
//                        .multilineTextAlignment(.leading)
                    
                    // 위치 (있는 경우)
//                    if let location = activity.location {
//                        HStack {
//                            Image(systemName: "location.fill")
//                                .foregroundColor(.white.opacity(0.8))
//                                .font(.caption)
//                            Text(location)
//                                .font(.caption)
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                    }
                }
            }
            .padding(20)
        }
        .frame(width: 350, height: 450)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}



#Preview {
    HomeView(viewModel: HomeViewModel(activityService: MockActivityService()))
}
