//
//  HorizontallyCenteredCollectionViewLayout.swift
//  godtools
//
//  Created by Levi Eggert on 1/28/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class HorizontallyCenteredCollectionViewLayout: UICollectionViewLayout {
      
    private let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var layoutAttributes: [UICollectionViewLayoutAttributes] = Array()
    private var cellSize: HorizontallyCenteredCollectionViewCellSize = .fixed(width: 240, height: 240)
    private var cellSpacing: CGFloat = 20
    private var layoutInitialized: Bool = false
    private var shouldReloadLayout: Bool = false
    private var lastPanningPoint: CGPoint = .zero
    
    private(set) var panDirection: HorizontallyCenteredCollectionViewPanDirection = .none
    private(set) var isPanning: Bool = false
        
    override init() {
        
        super.init()
        
        initialize(cellSize: cellSize, cellSpacing: cellSpacing)
    }
    
    required init(cellSize: HorizontallyCenteredCollectionViewCellSize, cellSpacing: CGFloat) {
        
        super.init()
        
        initialize(cellSize: cellSize, cellSpacing: cellSpacing)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        initialize(cellSize: cellSize, cellSpacing: cellSpacing)
    }
    
    private func initialize(cellSize: HorizontallyCenteredCollectionViewCellSize, cellSpacing: CGFloat) {
        
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
    }
    
    override func prepare() {
        
        if !layoutInitialized {
            
            layoutInitialized = true
            
            panGesture.addTarget(self, action: #selector(handlePanGesture))
            panGesture.delegate = self
            
            if let collectionView = collectionView {
                
                collectionView.isPagingEnabled = false
                collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
                collectionView.addGestureRecognizer(panGesture)
            }
        }

        let numberOfLayoutAttributes: Int = layoutAttributes.count
        let numberOfItemsInCollectionView: Int = getNumberOfItemsInCollectionView()
        
        if numberOfLayoutAttributes == 0 || numberOfLayoutAttributes != numberOfItemsInCollectionView {
            
            shouldReloadLayout = true
            
            layoutAttributes.removeAll()
        }
        
        let frameSize: CGSize = getCollectionViewFrame().size
        var prevFrameLayout: CGRect = CGRect.zero
        
        for index in 0 ..< numberOfItemsInCollectionView {
            
            let indexPath: IndexPath = IndexPath(item: index, section: 0)
            
            let collectionViewLayoutAttributes: UICollectionViewLayoutAttributes
            
            if !shouldReloadLayout {
                collectionViewLayoutAttributes = layoutAttributes[index]
            }
            else {
                collectionViewLayoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                layoutAttributes.append(collectionViewLayoutAttributes)
            }
            
            var frameLayout: CGRect = CGRect()
            
            frameLayout.origin.x = 0
            frameLayout.origin.y = frameSize.height / 2 -  cellSize.height / 2
            frameLayout.size.width = cellSize.width
            frameLayout.size.height = cellSize.height
            
            if index > 0 {
                frameLayout.origin.x = prevFrameLayout.origin.x + prevFrameLayout.size.width + cellSpacing
            }
            else {
                frameLayout.origin.x = frameSize.width / 2 - cellSize.width / 2
            }
            
            collectionViewLayoutAttributes.frame = frameLayout
        
            if let collectionView = collectionView, let cell = collectionView.cellForItem(at: indexPath) as? HorizontallyCenteredCollectionViewCell {
                
                cell.horizontallyCenteredCellDidUpdatePercentageVisible(percentageVisible: getPercentageVisibleForItemAtIndexPath(indexPath: indexPath), animated: true)
            }
            
            prevFrameLayout = frameLayout
        }
        
        shouldReloadLayout = false
    }
    
    override var collectionViewContentSize: CGSize {
        
        var width: CGFloat = 0
        
        if let lastLayoutAttributes = layoutAttributes.last {
            
            let frame: CGRect = lastLayoutAttributes.frame
            
            width = frame.origin.x + frame.size.width + (cellSpacing * 2)
        }
        
        let height: CGFloat = getCollectionViewFrame().size.height
        
        return CGSize(width: width, height: height)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var intersectingLayoutAttributes: [UICollectionViewLayoutAttributes] = Array()
        
        for layoutAttribute in layoutAttributes {
            
            if rect.intersects(layoutAttribute.frame) {
                
                intersectingLayoutAttributes.append(layoutAttribute)
            }
        }
        
        return intersectingLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return nil
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let contentOffset: CGPoint = getCollectionViewContentOffset()
        let interval: CGFloat = interval
        let itemIndex: CGFloat = floor(contentOffset.x / interval)
        
        let scrollToNext: Bool = velocity.x > 0 || (velocity.x == 0 && panDirection == .left)
        
        var targetPoint: CGPoint = proposedContentOffset
        
        if scrollToNext {
            targetPoint.x = itemIndex * interval + interval
        }
        else {
            targetPoint.x = itemIndex * interval
        }
                
        return super.targetContentOffset(forProposedContentOffset: targetPoint, withScrollingVelocity: velocity)
    }
    
    var interval: CGFloat {
        return cellSize.width + cellSpacing
    }
        
    func getLayoutAttributesAtIndexPath(indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let count: Int = layoutAttributes.count
        let index: Int = indexPath.row
        
        if !layoutAttributes.isEmpty && index >= 0 && index < count {
            return layoutAttributes[index]
        }
        
        return nil
    }
    
    func getGlobalPositionForItemAtIndexPath(indexPath: IndexPath) -> CGPoint {
        
        if let layoutAttributes = getLayoutAttributesAtIndexPath(indexPath: indexPath) {
            
            let localPosition: CGPoint = layoutAttributes.frame.origin
            let contentOffset: CGPoint = getCollectionViewContentOffset()
            
            let x: CGFloat = localPosition.x - contentOffset.x
            let y: CGFloat = localPosition.y - contentOffset.y
            
            return CGPoint(x: x, y: y)
        }
        
        return .zero
    }
    
    func getPercentageVisibleForItemAtIndexPath(indexPath: IndexPath) -> CGFloat {
        
        guard !layoutAttributes.isEmpty else {
            return 1
        }
        
        let frameSize: CGSize = getCollectionViewFrame().size
        let globalPosition: CGPoint = getGlobalPositionForItemAtIndexPath(indexPath: indexPath)
        let globalRestingPosition: CGFloat = frameSize.width / 2 - cellSize.width / 2
        
        var xOffset: CGFloat = globalPosition.x - globalRestingPosition
        let maxOffset: CGFloat = cellSize.width
        
        if xOffset < 0 {
            xOffset = xOffset * -1
        }
        
        if xOffset > maxOffset {
            xOffset = maxOffset
        }
        
        var percentage: CGFloat = 1 - (xOffset / maxOffset)
        
        if percentage < 0 {
            percentage = 0
        }
        else if percentage > 0.95 {
            percentage = 1
        }
        
        return percentage
    }
    
    func getMostVisibleIndexPath() -> IndexPath? {
        
        let visibleIndexPaths: [IndexPath] = getVisibleItems()
        
        var mostVisibleIndexPath: IndexPath?
        var visiblePercentage: CGFloat = 0
        var maxVisiblePercentage: CGFloat = 0
        
        for indexPath in visibleIndexPaths {
            
            visiblePercentage = getPercentageVisibleForItemAtIndexPath(indexPath: indexPath)
            
            if visiblePercentage > maxVisiblePercentage {
                
                maxVisiblePercentage = visiblePercentage
                
                mostVisibleIndexPath = indexPath
            }
        }
        
        return mostVisibleIndexPath
    }
    
    func getCenterPoint() -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            return .zero
        }
        
        let contentOffset: CGPoint = collectionView.contentOffset
        let frameSize: CGSize = collectionView.frame.size
        
        let centerPoint: CGPoint = CGPoint(x: contentOffset.x + frameSize.width / 2, y: contentOffset.y)
        
        return centerPoint
    }
    
    func getCenterIndexPath() -> IndexPath? {
        
        return collectionView?.indexPathForItem(at: getCenterPoint())
    }
    
    func getCenterCell() -> UICollectionViewCell? {
        
        guard let collectionView = self.collectionView, let indexPath = getCenterIndexPath() else {
            return nil
        }
        
        return collectionView.cellForItem(at: indexPath)
    }
        
    func getNumberOfItemsInCollectionView() -> Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    
    func getCollectionViewFrame() -> CGRect {
        return collectionView?.frame ?? .zero
    }
    
    func getCollectionViewContentOffset() -> CGPoint {
        return collectionView?.contentOffset ?? .zero
    }
    
    func getVisibleItems() -> [IndexPath] {
        return collectionView?.indexPathsForVisibleItems ?? Array()
    }
    
    func setCellSize(cellSize: HorizontallyCenteredCollectionViewCellSize, cellSpacing: CGFloat) {
        
        self.cellSize = cellSize
        self.cellSpacing = cellSpacing
        
        shouldReloadLayout = true
        
        invalidateLayout()
    }
        
    func reloadLayout() {
        
        layoutAttributes.removeAll()
        
        invalidateLayout()
    }
        
    @objc private func handlePanGesture() {
        
        let panGestureView: UIView? = panGesture.view
        
        let state: UIGestureRecognizer.State = panGesture.state
        let panningPoint: CGPoint = panGesture.translation(in: panGestureView)

        switch state {
            
        case .possible:
            break
        
        case .began:
            isPanning = true
            lastPanningPoint = panningPoint
        
        case .changed:
            if lastPanningPoint.x < panningPoint.x {
                panDirection = .right
            }
            else if lastPanningPoint.x > panningPoint.x {
                panDirection = .left
            }
            
            lastPanningPoint = panningPoint
        
        case .ended:
            isPanning = false
            lastPanningPoint = .zero
        
        case .cancelled:
            isPanning = false
            lastPanningPoint = .zero
        
        case .failed:
            isPanning = false
            lastPanningPoint = .zero
        
        @unknown default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension HorizontallyCenteredCollectionViewLayout: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
