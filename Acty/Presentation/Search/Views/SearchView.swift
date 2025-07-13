//
//  SearchView.swift
//  Acty
//
//  Created by Sebin Kwon on 7/13/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @StateObject var viewModel: SearchViewModel
    @State private var searchText = ""
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("검색")
                    .font(.paperLogy(.body1))
                    .foregroundStyle(.accent)
                Spacer()
            }
            .padding(20)
            
            searchBarView
            
            // 컨텐츠 영역
            contentView
        }
        .background(Color(.systemBackground))
        .onReceive(viewModel.output.errorMessage) { errorMessage in
            print("검색 에러: \(errorMessage)")
        }
    }
    
    // MARK: - 검색 바
    private var searchBarView: some View {
        searchInputSection
    }
    
    private var searchInputSection: some View {
        HStack(spacing: 12) {
            searchIcon
            searchField
            actionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .overlay(
            Capsule()
                .stroke(.gray60, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var searchIcon: some View {
        Image(systemName: "magnifyingglass")
            .foregroundColor(searchText.isEmpty ? .gray60 : .accent)
            .font(.system(size: 18, weight: .medium))
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
    
    private var searchField: some View {
        TextField("액티비티를 검색해보세요", text: $searchText)
            .focused($isSearchFieldFocused)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.body)
            .onSubmit {
                performSearch()
            }
            .onChange(of: searchText) { newValue in
                viewModel.input.searchTextChanged.send(newValue)
            }
    }
    
    private var actionButton: some View {
        Group {
            if !searchText.isEmpty {
                clearButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
    
    private var clearButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                searchText = ""
                viewModel.input.clearSearch.send(())
            }
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray60)
                .font(.system(size: 18))
        }
    }
    
    // MARK: - 컨텐츠 영역
    private var contentView: some View {
        Group {
            if viewModel.output.isLoading.value {
                loadingView
            } else if viewModel.output.searchResults.isEmpty && viewModel.output.hasSearched {
                emptyResultView
            } else if !viewModel.output.searchResults.isEmpty {
                searchResultsView
            } else {
                initialStateView
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.output.isLoading.value)
        .animation(.easeInOut(duration: 0.3), value: viewModel.output.searchResults.isEmpty)
    }
    
    // MARK: - 초기 상태 화면
    private var initialStateView: some View {
        VStack(spacing: 24) {
            if !viewModel.output.recentSearches.isEmpty {
                recentSearchesSection
            }
            initialContent
                .padding(.top, 110)
            Spacer()
        }
    }
    
    private var initialContent: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("원하는 액티비티를 검색해보세요")
                    .font(.pretendard(.body1(.bold)))
                    .foregroundColor(.gray75)
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("최근 검색어")
                    .font(.pretendard(.body3(.medium)))
                    .foregroundStyle(.gray75)
                
                Spacer()
                
                Button {
                    viewModel.input.clearRecentSearches.send(())
                } label: {
                    Text("전체 삭제")
                        .font(.pretendard(.caption1(.medium)))
                        .foregroundColor(.gray60)
                }
            }
            
            recentSearchesGrid
        }
        .padding(.horizontal, 16)
    }
    
    private var recentSearchesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(Array(viewModel.output.recentSearches.prefix(6)), id: \.self) { keyword in
                recentSearchButton(keyword: keyword)
            }
        }
    }
    
    private func recentSearchButton(keyword: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                searchText = keyword
                viewModel.input.recentSearchSelected.send(keyword)
            }
        } label: {
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.gray60)
                
                Text(keyword)
                    .font(.pretendard(.caption1(.medium)))
                    .foregroundColor(.gray90)
                
                Spacer()
                
                Button {
                    viewModel.input.removeRecentSearch.send(keyword)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 10))
                        .foregroundColor(.gray60)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white)
            .overlay(
                Capsule()
                    .stroke(.gray45, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - 로딩 상태
    private var loadingView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .deepBlue))
                .scaleEffect(1.2)
            
            Text("검색 중...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    // MARK: - 검색 결과 없음
    private var emptyResultView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "exclamationmark.magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("다른 키워드로 검색해보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    searchText = ""
                    viewModel.input.clearSearch.send(())
                }
            } label: {
                Text("다시 검색하기")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.deepBlue)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
    }
    
    // MARK: - 검색 결과 리스트
    private var searchResultsView: some View {
        VStack(spacing: 0) {
            searchResultsHeader
            searchResultsList
        }
    }
    
    private var searchResultsHeader: some View {
        HStack {
            Text("검색 결과")
                .font(.pretendard(.body2(.medium)))
                .foregroundColor(.gray90)
            
            Text("(\(viewModel.output.searchResults.count)개)")
                .font(.pretendard(.caption1(.medium)))
                .foregroundColor(.gray75)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.output.searchResults, id: \.id) { activity in
                    ActivityCell(activity: activity)
                        .padding(.horizontal, 16)
                        .onTapGesture {
                            navigationRouter.navigate(to: .activityDetails(detailId: activity.id), in: .main)
                        }
                        .onAppear {
                            // 무한 스크롤 처리 (필요한 경우)
                            if activity.id == viewModel.output.searchResults.last?.id {
                                viewModel.input.loadMoreResults.send(())
                            }
                        }
                }
            }
            .padding(.bottom, 80)
        }
    }
    
    // MARK: - Helper Methods
    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSearchFieldFocused = false
        viewModel.input.searchTriggered.send(searchText.trimmingCharacters(in: .whitespacesAndNewlines))
    }
}

#Preview {
    NavigationView {
        SearchView(viewModel: SearchViewModel(activityService: MockActivityService()))
    }
    .environmentObject(NavigationRouter())
}
