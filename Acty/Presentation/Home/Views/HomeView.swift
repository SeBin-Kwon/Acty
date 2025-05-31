//
//  HomeView.swift
//  Acty
//
//  Created by Sebin Kwon on 5/10/25.
//

import SwiftUI

struct HomeView: View {
    
    @State private var selectedCountry: Country = .Korea
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {                filterRow
            }
            .padding(20)
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
    
    private func countryFilterButton(_ country: Country) -> some View {
        
        Button {
            selectedCountry = country
        } label: {
            HStack(spacing: 12) {
                
                Image(country.rawValue)
                Text(country.koreaName)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedCountry == country ? .accent.opacity(0.5) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        selectedCountry == country ? .accent : Color.gray.opacity(0.3),
                        lineWidth: selectedCountry == country ? 2 : 1
                    )
            )
        }
        .foregroundColor(selectedCountry == country ? .blue : .primary)
    }
}


private enum Country: String, CaseIterable {
    case Korea, Japan, Australia, Philippines, Taiwan, Thailand, Argentina
    
    var koreaName: String {
        switch self {
        case .Korea: "대한민국"
        case .Japan: "일본"
        case .Australia: "호주"
        case .Philippines: "필리핀"
        case .Thailand: "태국"
        case .Taiwan: "대만"
        case .Argentina: "아르헨티나"
        }
    }
}


#Preview {
    HomeView()
}
