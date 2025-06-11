//
//  HomeView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedCountry: Country? = nil
    @State private var selectedCategory: ActivityCategory? = nil
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack() {
                HStack {
                    Text("NEW 액티비티")
                        .font(.pretendard(.body2(.bold)))
                        .padding(20)
                    Spacer()
                }
                ActivityCarouselListView(activities: viewModel.output.newActivityList) { activity in
                    ActivityBannerView(activity: activity)
                }
                .frame(height: 320)
                countryFilterRow
                categoryFilterRow
                activityListView
            }
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
    
    private var activityListView: some View {
        ForEach(viewModel.output.activityList, id: \.id) { activity in
            ActivityCell(activity: activity)
        }
        .allowsHitTesting(false)
        .padding(.horizontal, 20)
    }
    
    private var countryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Country.allCases, id: \.rawValue) { country in
                    countryFilterButton(country)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
    
    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(ActivityCategory.allCases, id: \.rawValue) { category in
                    categoryFilterButton(category)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private func countryFilterButton(_ country: Country) -> some View {
        HStack(spacing: 12) {
            
            Image(country.rawValue)
            Text(country.koreaName)
            
                .foregroundColor(selectedCountry == country ? .accent : .primary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(selectedCountry == country ? .accent.opacity(0.2) : .white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(selectedCountry == country ? .accent : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .clipShape(.rect(cornerRadius: 10))
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
            print("d")
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

//
//#Preview {
//    HomeView(viewModel: HomeViewModel(activityService: MockActivityService()))
//}
