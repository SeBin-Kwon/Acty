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
                activityList
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
    
    private var activityList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(viewModel.output.activityList, id: \.id) { activity in
                    LazyImage(url: URL(string: activity.thumbnails.first!)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if state.error != nil {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.blue.opacity(0.6), Color.cyan.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                )
                        }
                    }
                    .frame(width: 350, height: 450)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    Text(activity.title)
                }
            }
        }
    }
    
    private func newActivityCard(_ activity: Activity) -> some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(Color.gray.opacity(0.2))
    }
    
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


#Preview {
    HomeView(viewModel: HomeViewModel(activityService: MockActivityService()))
}
