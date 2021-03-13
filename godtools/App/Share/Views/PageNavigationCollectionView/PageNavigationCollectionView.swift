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
    
    @objc optional func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView, page: Int)
    @objc optional func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageWillAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageWillDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
}

class PageNavigationCollectionView: UIView, NibBased {
    
    private let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
    private var internalCurrentChangedPage: Int = 0
    private var internalCurrentStoppedOnPage: Int = 0
    private var shouldNotifyPageDidAppearForDataReload: Bool = false
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    weak var delegate: PageNavigationCollectionViewDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        
        loadNib()
        setupLayout()
        
        shouldNotifyPageDidAppearForDataReload = true
        
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
        collectionView.contentInset = .zero
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
        shouldNotifyPageDidAppearForDataReload = true
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
    
    func scrollToFirstPage(animated: Bool) {
        scrollToPage(page: 0, animated: animated)
    }
    
    func scrollToLastPage(animated: Bool) {
        scrollToPage(page: numberOfPages - 1, animated: animated)
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
        let numberOfPages: Int = self.numberOfPages
        return currentPage >= numberOfPages - 1 && numberOfPages > 0
    }
    
    var numberOfPages: Int {
        return collectionView.numberOfItems(inSection: 0)
    }
    
    var pagesCollectionView: UICollectionView {
        return collectionView
    }
    
    var pageBackgroundColor: UIColor = UIColor.white {
        didSet {
            backgroundColor = pageBackgroundColor
            subviews.first?.backgroundColor = pageBackgroundColor
            collectionView.backgroundColor = pageBackgroundColor
            collectionView.reloadData()
        }
    }
    
    private func didEndPageScrolling() {
        
        let currentPage: Int = self.currentPage
        if internalCurrentStoppedOnPage != currentPage {
            internalCurrentStoppedOnPage = currentPage
            
            let indexPath = IndexPath(item: currentPage, section: 0)
            if let pageCell = collectionView.cellForItem(at: indexPath) {
                pageDidAppear(pageCell: pageCell, page: currentPage)
            }
        }
    }
    
    // MARK: -
    
    private func mostVisiblePageChanged(pageCell: UICollectionViewCell, page: Int) {
        delegate?.pageNavigationDidChangeMostVisiblePage?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageWillAppear(pageCell: UICollectionViewCell, page: Int) {
        delegate?.pageNavigationPageWillAppear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidAppear(pageCell: UICollectionViewCell, page: Int) {
        delegate?.pageNavigationPageDidAppear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageWillDisappear(pageCell: UICollectionViewCell, page: Int) {
        delegate?.pageNavigationPageWillDisappear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidDisappear(pageCell: UICollectionViewCell, page: Int) {
        delegate?.pageNavigationPageDidDisappear?(pageNavigation: self, pageCell: pageCell, page: page)
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
        
        let cell: UICollectionViewCell? = delegate?.pageNavigation(pageNavigation: self, cellForPageAt: indexPath)
        
        cell?.backgroundColor = pageBackgroundColor
        cell?.contentView.backgroundColor = pageBackgroundColor
        
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let page: Int = indexPath.row
        
        pageWillAppear(pageCell: cell, page: page)
        
        if shouldNotifyPageDidAppearForDataReload {
            shouldNotifyPageDidAppearForDataReload = false
            mostVisiblePageChanged(pageCell: cell, page: page)
            pageDidAppear(pageCell: cell, page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageDidDisappear(pageCell: cell, page: indexPath.row)
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
        
        let currentPage: Int = self.currentPage
        
        delegate?.pageNavigationDidScrollPage?(pageNavigation: self, page: currentPage)
        
        if internalCurrentChangedPage != currentPage {
            internalCurrentChangedPage = currentPage
            let indexPath = IndexPath(item: currentPage, section: 0)
            if let pageCell = collectionView.cellForItem(at: indexPath) {
                mostVisiblePageChanged(pageCell: pageCell, page: currentPage)
            }
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
