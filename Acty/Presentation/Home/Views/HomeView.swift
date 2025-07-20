//
//  HomeView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI
import NukeUI

struct HomeView: View {
    
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject var viewModel: HomeViewModel
    @State private var selectedCountry: Country? = nil
    @State private var selectedCategory: ActivityCategory? = nil
    
    @State private var currentBannerIndex = 0
    @State private var bannerTimer: Timer?
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                
                bannerSection
                
                ActivityCarouselListView(activities: viewModel.output.newActivityList) { activity in
                    ActivityBannerView(activity: activity)
                        .onTapGesture {
                            navigationRouter.navigate(to: .activityDetails(detailId: activity.id), in: .main)
                        }
                }
                .padding(.top, 10)
                .padding(.bottom, -20)
                .frame(height: 320)
                HStack {
                    Text("액티비티 둘러보기")
                        .font(.paperLogy(.body1))
                        .foregroundStyle(.accent)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    Spacer()
                }
                countryFilterRow
                categoryFilterRow
                activityListView
                if viewModel.output.isLoading {
                    loadingView
                }
            }
        }
        .onAppear {
            viewModel.input.onAppear.send(())
        }
        .onReceive(viewModel.output.bannersLoaded) { _ in
            startBannerTimer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("액티")
                    .font(.paperLogy(.body1))
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
    
    private var bannerSection: some View {
        VStack(spacing: 0) {
            if !viewModel.output.banners.isEmpty {
                TabView(selection: $currentBannerIndex) {
                    ForEach(Array(viewModel.output.banners.enumerated()), id: \.offset) { index, banner in
                        BannerView(banner: banner) {
                            viewModel.input.bannerTapped.send(banner)
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                .frame(height: 100)
                .onChange(of: currentBannerIndex) { _ in
                    restartBannerTimer()
                }
            }
        }
    }
    
    // 배너 타이머 관리
    private func startBannerTimer() {
        guard !viewModel.output.banners.isEmpty else { return }
        
        bannerTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentBannerIndex = (currentBannerIndex + 1) % viewModel.output.banners.count
            }
        }
    }
    
    private func stopBannerTimer() {
        bannerTimer?.invalidate()
        bannerTimer = nil
    }
    
    private func restartBannerTimer() {
        stopBannerTimer()
        startBannerTimer()
    }
}

struct BannerView: View {
    let banner: Banner
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            LazyImage(url: URL(string: banner.fullImageURL)) { state in
                if let image = state.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if state.error != nil {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay(
                            Text(banner.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
            }
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .overlay(
//                // 배너 제목 오버레이
//                VStack {
//                    Spacer()
//                    HStack {
//                        Text(banner.name)
//                            .font(.headline)
//                            .fontWeight(.bold)
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(
//                                LinearGradient(
//                                    colors: [Color.black.opacity(0.6), Color.clear],
//                                    startPoint: .bottom,
//                                    endPoint: .top
//                                )
//                            )
//                        Spacer()
//                    }
//                }
//            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}


extension HomeView {
    
    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("로딩 중...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var activityListView: some View {
        ForEach(Array(viewModel.output.activityList.enumerated()), id: \.offset) { index, activity in
            ActivityCell(activity: activity)
                .onTapGesture {
                    navigationRouter.navigate(to: .activityDetails(detailId: activity.id), in: .main)
                }
                .onAppear {
                    if index == viewModel.output.activityList.count - 3 {
                        viewModel.input.loadData.send(())
                    }
                }
        }
        .padding(.horizontal, 20)
    }
    
    private var countryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Country.allCases, id: \.rawValue) { country in
                    countryFilterButton(country)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 5)
    }
    
    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(ActivityCategory.allCases, id: \.rawValue) { category in
                    categoryFilterButton(category)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 15)
    }
    
    private func countryFilterButton(_ country: Country) -> some View {
        HStack(spacing: 12) {
            Image(country.rawValue)
            Text(country.koreaName)
                .font(.pretendard(.body3(selectedCountry == country ? .bold : .medium)))
                .foregroundColor(selectedCountry == country ? .accent : .gray75)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(selectedCountry == country ? .accent.opacity(0.2) : .white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(selectedCountry == country ? .accent : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .clipShape(.rect(cornerRadius: 12))
        .wrapToButton {
            withAnimation {
                if selectedCountry == country {
                    selectedCountry = nil
                } else {
                    selectedCountry = country
                }
                viewModel.input.filterButtonTapped.send((selectedCountry, selectedCategory))
            }
        }
    }
    
    private func categoryFilterButton(_ category: ActivityCategory) -> some View {
        Button(category.koreaName) {
            withAnimation {
                if selectedCategory == category {
                    selectedCategory = nil
                } else {
                    selectedCategory = category
                }
                viewModel.input.filterButtonTapped.send((selectedCountry, selectedCategory))
            }
        }
        .buttonStyle(.actySelected(selectedCategory == category))
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(activityService: MockActivityService(), bannerService: MockBannerService()))
}
