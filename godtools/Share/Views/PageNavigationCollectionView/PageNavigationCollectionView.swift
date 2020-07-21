//
//  PageNavigationCollectionView.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@objc protocol PageNavigationCollectionViewDelegate: class {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell
    @objc optional func pageNavigation(pageNavigation: PageNavigationCollectionView, willDisplay pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath)
    @objc optional func pageNavigation(pageNavigation: PageNavigationCollectionView, didEndDisplaying pageCell: UICollectionViewCell, forPageAt indexPath: IndexPath)
    func pageNavigationDidChangePage(pageNavigation: PageNavigationCollectionView, page: Int)
    func pageNavigationDidStopOnPage(pageNavigation: PageNavigationCollectionView, page: Int)
    @objc optional func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView)
}

class PageNavigationCollectionView: UIView, NibBased {
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
    private var internalCurrentChangedPage: Int = 0
    private var internalCurrentStoppedOnPage: Int = 0
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    weak var delegate: PageNavigationCollectionViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        loadNib()
        setupLayout()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupLayout() {
        
        //collectionView
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
    
    // MARK: -
    
    func registerPageCell(nib: UINib?, cellReuseIdentifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    func getReusablePageCell(cellReuseIdentifier: String, indexPath: IndexPath) -> UICollectionViewCell {        
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: -
    
    func scrollToPreviousPage(animated: Bool) {
        if !isOnFirstPage {
            scrollToPage(page: currentPage - 1, animated: animated)
        }
    }
    
    func scrollToNextPage(animated: Bool) {
        if !isOnLastPage {
            scrollToPage(page: currentPage + 1, animated: animated)
        }
    }
    
    func scrollToPage(page: Int, animated: Bool) {
        
        guard numberOfPages > 0 else {
            return
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: page, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
    }
    
    // MARK: -
    
    var gestureScrollingEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = gestureScrollingEnabled
            collectionView.isPagingEnabled = gestureScrollingEnabled
        }
    }
    
    var currentPage: Int {
        
        guard !collectionView.visibleCells.isEmpty else {
            return 0
        }
        
        let contentOffsetX: CGFloat = abs(collectionView.contentOffset.x)
        let pageWidth: CGFloat = bounds.size.width
        
        var closestToZeroIndexPath: IndexPath?
        var closestToZeroOffsetX: CGFloat = pageWidth
        
        for cellIndexPath in collectionView.indexPathsForVisibleItems {
            
            if let layoutAttributes = collectionView.layoutAttributesForItem(at: cellIndexPath) {
                
                let cellOffsetX: CGFloat = abs(contentOffsetX - layoutAttributes.frame.origin.x)
                
                if cellOffsetX < closestToZeroOffsetX {
                    closestToZeroOffsetX = cellOffsetX
                    closestToZeroIndexPath = cellIndexPath
                }
            }
        }
        
        if let indexPath = closestToZeroIndexPath {
            return indexPath.row
        }
        
        return 0
    }
    
    var isOnFirstPage: Bool {
        return currentPage == 0
    }
    
    var isOnLastPage: Bool {
        return currentPage >= numberOfPages - 1
    }
    
    var numberOfPages: Int {
        return collectionView.numberOfItems(inSection: 0)
    }
    
    var pagesCollectionView: UICollectionView {
        return collectionView
    }
    
    private func didEndPageScrolling() {
        
        let currentPage: Int = self.currentPage
        if internalCurrentStoppedOnPage != currentPage {
            internalCurrentStoppedOnPage = currentPage
            delegate?.pageNavigationDidStopOnPage(pageNavigation: self, page: internalCurrentStoppedOnPage)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout, UICollectionViewDataSource

extension PageNavigationCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return delegate?.pageNavigationNumberOfPages(pageNavigation: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return delegate?.pageNavigation(pageNavigation: self, cellForPageAt: indexPath) ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.pageNavigation?(pageNavigation: self, willDisplay: cell, forPageAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        delegate?.pageNavigation?(pageNavigation: self, didEndDisplaying: cell, forPageAt: indexPath)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - UIScrollViewDelegate

extension PageNavigationCollectionView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        delegate?.pageNavigationDidScrollPage?(pageNavigation: self)
        
        let currentPage: Int = self.currentPage
        if internalCurrentChangedPage != currentPage {
            internalCurrentChangedPage = currentPage
            delegate?.pageNavigationDidChangePage(pageNavigation: self, page: internalCurrentChangedPage)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            didEndPageScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        didEndPageScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        didEndPageScrolling()
    }
}
