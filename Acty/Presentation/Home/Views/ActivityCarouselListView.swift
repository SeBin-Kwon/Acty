//
//  ActivityCarouselListView.swift
//  Acty
//
//  Created by Sebin Kwon on 6/10/25.
//

import UIKit
import SwiftUI

struct ActivityCarouselListView<Cell: View>: UIViewRepresentable {
    typealias DataSource = UICollectionViewDiffableDataSource<String, Activity>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, Activity>
    typealias Registration = UICollectionView.CellRegistration<UICollectionViewCell, Activity>
    
    private let activities: [Activity]
    private let cell: (Activity) -> Cell
    @Binding private var selectedIndex: Int
    
    init(activities: [Activity], selectedIndex: Binding<Int> = .constant(0), cell: @escaping (Activity) -> Cell) {
        self.activities = activities
        self._selectedIndex = selectedIndex
        self.cell = cell
    }
    
    func makeUIView(context: Context) -> UICollectionView {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: configureCompositionalLayout()
        )
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = context.coordinator
        
        configureDataSource(collectionView, coordinator: context.coordinator)
        applySnapshot(coordinator: context.coordinator)
        return collectionView
    }
    
    func updateUIView(_ uiView: UICollectionView, context: Context) {
        context.coordinator.activities = activities
        context.coordinator.selectedIndex = $selectedIndex
        applySnapshot(coordinator: context.coordinator)
        
        // 선택된 인덱스로 스크롤 (업데이트 시)
        if selectedIndex < activities.count {
            DispatchQueue.main.async {
                uiView.scrollToItem(
                    at: IndexPath(item: selectedIndex, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectedIndex: $selectedIndex, activities: activities)
    }
}

// MARK: - Coordinator
extension ActivityCarouselListView {
    final class Coordinator: NSObject, UICollectionViewDelegate {
        var dataSource: DataSource?
        var selectedIndex: Binding<Int>
        var activities: [Activity]
        
        init(selectedIndex: Binding<Int>, activities: [Activity]) {
            self.selectedIndex = selectedIndex
            self.activities = activities
        }
        
        // 셀 탭 처리
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedIndex.wrappedValue = indexPath.item
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        // 스크롤 완료 시 선택된 인덱스 업데이트
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            updateSelectedIndex(scrollView)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate {
                updateSelectedIndex(scrollView)
            }
        }
        
        private func updateSelectedIndex(_ scrollView: UIScrollView) {
            guard let collectionView = scrollView as? UICollectionView else { return }
            
            let centerX = scrollView.contentOffset.x + scrollView.bounds.width / 2
            var closestIndexPath: IndexPath?
            var minDistance: CGFloat = .greatestFiniteMagnitude
            
            for indexPath in collectionView.indexPathsForVisibleItems {
                if let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
                    let distance = abs(attributes.center.x - centerX)
                    if distance < minDistance {
                        minDistance = distance
                        closestIndexPath = indexPath
                    }
                }
            }
            
            if let indexPath = closestIndexPath, indexPath.item != selectedIndex.wrappedValue {
                selectedIndex.wrappedValue = indexPath.item
            }
        }
    }
}

// MARK: - Configure Views
private extension ActivityCarouselListView {
    func configureDataSource(
        _ collectionView: UICollectionView,
        coordinator: Coordinator
    ) {
        let registration = Registration { cell, _, activity in
            cell.contentConfiguration = UIHostingConfiguration {
                self.cell(activity)
            }
        }
        
        coordinator.dataSource = DataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.configureSectionLayout()
        }
        return layout
    }
    
    func configureSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(300), // ActivityBannerView 크기에 맞춤
            heightDimension: .absolute(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
//        section.interGroupSpacing = 20  카드 간격
        section.orthogonalScrollingBehavior = .groupPagingCentered // 중앙 정렬 + 페이징
        
        // 실시간 스케일 + 투명도 애니메이션
        section.visibleItemsInvalidationHandler = { items, offset, environment in
            let containerWidth = environment.container.contentSize.width
            let maxDistance = containerWidth / 2
            
            for item in items {
                let itemCenterX = item.center.x - offset.x
                let distanceFromCenter = abs(containerWidth / 2 - itemCenterX)
                let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
                
                // 스케일 효과 (중앙: 1.0, 양쪽: 0.8)
                let minScale: CGFloat = 0.8
                let scale = 1.0 - (normalizedDistance * (1.0 - minScale))
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                
                // 투명도 효과 (중앙: 1.0, 양쪽: 0.6)
                let minAlpha: CGFloat = 0.6
                let alpha = 1.0 - (normalizedDistance * (1.0 - minAlpha))
                item.alpha = alpha
            }
        }
        
        return section
    }
    
    func applySnapshot(coordinator: Coordinator) {
        var snapshot = Snapshot()
        snapshot.appendSections(["ActivitySection"])
        snapshot.appendItems(activities, toSection: "ActivitySection")
        coordinator.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}
