//
//  HomeView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedCountry: Country? = nil
    @State private var selectedCategory: Category? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                filterRow
                categoryFilterRow
            }
            .padding(20)
        }
        .onAppear {
            
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


//#Preview {
//    HomeView()
//}
