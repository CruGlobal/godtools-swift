//
//  PageNavigationCollectionViewCenteredLayout.swift
//  godtools
//
//  Created by Levi Eggert on 8/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import UIKit

class PageNavigationCollectionViewCenteredLayout: UICollectionViewFlowLayout {
    
    enum PanDirection {
        
        case left
        case none
        case right
    }
    
    private let layoutType: PageNavigationCollectionViewLayoutType
    private let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var layoutInitialized: Bool = false
    private var panGuestureAdded: Bool = false
    private var beginningPanPoint: CGPoint?
    private var beginningContentOffset: CGPoint?
    private var lastPanningPoint: CGPoint = .zero
        
    private(set) var panDirection: PageNavigationCollectionViewCenteredLayout.PanDirection = .none
    private(set) var isPanning: Bool = false
    
    private weak var pageNavigationCollectionView: PageNavigationCollectionView?
    
    init(layoutType: PageNavigationCollectionViewLayoutType, pageNavigationCollectionView: PageNavigationCollectionView) {
        
        self.layoutType = layoutType
        self.pageNavigationCollectionView = pageNavigationCollectionView
        
        super.init()
        
        addPanGestureIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
            
        if !layoutInitialized {
            layoutInitialized = true
            
            addPanGestureIfNeeded()
            
            if let collectionView = collectionView {
                            
                collectionView.isPagingEnabled = false
                collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
                collectionView.addGestureRecognizer(panGesture)
            }
        }
        
        super.prepare()
    }
    
    override var flipsHorizontallyInOppositeLayoutDirection: Bool {
        
        // NOTE: Settings this to true will cause the coordinate system to flip when the device system language is right to left.  Meaning the contentOffset will flip.
        // Without setting this to true, when the device language is right to left, the collection view will correctly call cellForRow at 0 and scroll right to left correctly.  However,
        // the contentOffset wouldn't start at 0 and would instead start at the end as if the collectionView were scrolling left to right. ~Levi
        
        return true
    }
    
    private func addPanGestureIfNeeded() {
        
        guard let collectionView = self.collectionView, !panGuestureAdded else {
            return
        }
        
        panGuestureAdded = true
        
        panGesture.addTarget(self, action: #selector(handlePanGesture))
        panGesture.delegate = self
        collectionView.addGestureRecognizer(panGesture)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let pageNavigationCollectionView = pageNavigationCollectionView else {
            return .zero
        }
                        
        let currentPage: Int = pageNavigationCollectionView.getPageBasedOnContentOffset(contentOffset: proposedContentOffset)
        
        let targetPage: Int
        
        if let beginningPanPoint = self.beginningPanPoint, let beginningContentOffset = self.beginningContentOffset {
            
            let beginningPage: Int = pageNavigationCollectionView.getPageBasedOnContentOffset(contentOffset: beginningContentOffset)
            
            switch panDirection {
            
            case .left:
                
                if lastPanningPoint.x < beginningPanPoint.x {
                    targetPage = beginningPage + 1
                }
                else {
                    targetPage = beginningPage
                }
            
            case .none:
                targetPage = beginningPage
            
            case .right:
                
                if lastPanningPoint.x > beginningPanPoint.x {
                    targetPage = beginningPage - 1
                }
                else {
                    targetPage = beginningPage
                }
            }
        }
        else {
            
            targetPage = currentPage
        }
        
        let targetPageFloat: CGFloat = CGFloat(targetPage)
                
        let targetContentOffset = CGPoint(
            x: (pageNavigationCollectionView.getPageSize().width * targetPageFloat) + (pageNavigationCollectionView.getPageSpacing() * targetPageFloat),
            y: 0
        )
                
        return super.targetContentOffset(forProposedContentOffset: targetContentOffset, withScrollingVelocity: velocity)
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
            beginningPanPoint = panningPoint
            beginningContentOffset = pageNavigationCollectionView?.getContentOffset()
        
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
            beginningPanPoint = nil
            beginningContentOffset = nil
        
        case .cancelled:
            isPanning = false
            lastPanningPoint = .zero
            beginningPanPoint = nil
            beginningContentOffset = nil
        
        case .failed:
            isPanning = false
            lastPanningPoint = .zero
            beginningPanPoint = nil
            beginningContentOffset = nil
        
        @unknown default:
            break
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PageNavigationCollectionViewCenteredLayout: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
