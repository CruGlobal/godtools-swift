//
//  PageNavigationCollectionView.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

@objc protocol PageNavigationCollectionViewDelegate: AnyObject {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell
    
    @objc optional func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView, page: Int)
    @objc optional func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationDidEndScrollingAnimation(pageNavigation: PageNavigationCollectionView)
    @objc optional func pageNavigationDidEndPageScrolling(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
}

class PageNavigationCollectionView: UIView, NibBased {
    
    struct CurrentNavigation {
        let pageNavigation: PageNavigationCollectionViewNavigationModel
        let isNavigationFromDataReload: Bool
    }
    
    private let layout: UICollectionViewLayout
    private let loggingEnabled: Bool = false
    
    private var currentPageNavigation: PageNavigationCollectionView.CurrentNavigation?
    private var pageNavigationCompletedClosure: ((_ completed: PageNavigationCollectionViewNavigationCompleted) -> Void)?
    private var internalCurrentChangedPage: Int = -1
    private var internalCurrentStoppedOnPage: Int = -1
            
    @IBOutlet weak private var collectionView: UICollectionView!
    
    weak var delegate: PageNavigationCollectionViewDelegate?
    
    required init(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        
        self.layout = layout
        super.init(frame: UIScreen.main.bounds)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        self.layout = UICollectionViewFlowLayout()
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
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        collectionView.semanticContentAttribute = .forceLeftToRight
        
        if #available(iOS 16, *) {
            collectionView.selfSizingInvalidation = .disabled
        }
    }
    
    // MARK: -
    
    func registerPageCell(nib: UINib?, cellReuseIdentifier: String) {
        collectionView.register(nib, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    func registerPageCell(classClass: AnyClass?, cellReuseIdentifier: String) {
        collectionView.register(classClass, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    func getReusablePageCell(cellReuseIdentifier: String, indexPath: IndexPath) -> UICollectionViewCell {        
        return collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
    
    // MARK: -
    
    var pageBackgroundColor: UIColor = UIColor.white {
        didSet {
            backgroundColor = pageBackgroundColor
            subviews.first?.backgroundColor = pageBackgroundColor
            collectionView.backgroundColor = pageBackgroundColor
            collectionView.reloadData()
        }
    }
    
    var gestureScrollingEnabled: Bool = true {
        didSet {
            collectionView.isScrollEnabled = gestureScrollingEnabled
            collectionView.isPagingEnabled = gestureScrollingEnabled
        }
    }
    
    var currentPageCell: UICollectionViewCell? {
        
        let currentPage: Int = self.currentPage
        
        return collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0))
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
    
    func setPagingEnabled(pagingEnabled: Bool) {
        collectionView.isPagingEnabled = pagingEnabled
    }
    
    func setContentInset(contentInset: UIEdgeInsets) {
        collectionView.contentInset = contentInset
        collectionView.reloadData()
    }
    
    func setContentInsetAdjustmentBehavior(contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior) {
        collectionView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
    }
    
    func getContentOffset() -> CGPoint {
        return collectionView.contentOffset
    }
    
    func setContentOffset(contentOffset: CGPoint, animated: Bool) {
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    func getSemanticContentAttribute() -> UISemanticContentAttribute {
        return collectionView.semanticContentAttribute
    }
    
    func setSemanticContentAttribute(semanticContentAttribute: UISemanticContentAttribute) {
            
        guard semanticContentAttribute != collectionView.semanticContentAttribute else {
            return
        }
        
        collectionView.semanticContentAttribute = semanticContentAttribute
    }
    
    func getIndexPathForPageCell(pageCell: UICollectionViewCell) -> IndexPath? {
        return collectionView.indexPath(for: pageCell)
    }
    
    func getCellAtIndex(index: Int) -> UICollectionViewCell? {
        return getCellForItem(indexPath: IndexPath(item: index, section: 0))
    }
    
    func getCellForItem(indexPath: IndexPath) -> UICollectionViewCell? {
        return collectionView.cellForItem(at: indexPath)
    }
    
    func getVisiblePageCells() -> [UICollectionViewCell] {
        return collectionView.visibleCells
    }
    
    private func logMessage(message: String) {
        
        guard loggingEnabled else {
            return
        }
        
        print("\n PageNavigationCollectionView: \(message)")
    }
}

// MARK: - Page Life Cycle

extension PageNavigationCollectionView {
    
    private func mostVisiblePageChanged(pageCell: UICollectionViewCell, page: Int) {
        
        logMessage(message: "most visible page changed: \(page)")
        
        delegate?.pageNavigationDidChangeMostVisiblePage?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidAppear(pageCell: UICollectionViewCell, page: Int) {
        
        logMessage(message: "page did appear: \(page)")
        
        delegate?.pageNavigationPageDidAppear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidDisappear(pageCell: UICollectionViewCell, page: Int) {
        
        logMessage(message: "page did disappear: \(page)")
        
        delegate?.pageNavigationPageDidDisappear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
}

// MARK: - Insert/Delete Pages

extension PageNavigationCollectionView {
    
    func insertPagesAt(indexes: [Int]) {
        
        logMessage(message: "insert pages at: \(indexes)")
                
        let indexPaths: [IndexPath] = indexes.map({IndexPath(item: $0, section: 0)})
        
        collectionView.insertItems(at: indexPaths)
    }
    
    func deletePagesAt(indexes: [Int]) {
        
        guard indexes.count > 0 else {
            return
        }
        
        guard numberOfPages > 0 else {
            return
        }
        
        logMessage(message: "delete pages at: \(indexes)")
                
        let indexPaths: [IndexPath] = indexes.map({IndexPath(item: $0, section: 0)})
        
        let currentPage: Int = self.currentPage
        var pageNumberForDeletedPages: Int = currentPage
        
        for indexPath in indexPaths {
            if indexPath.item < currentPage {
                pageNumberForDeletedPages -= 1
            }
        }
                
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: indexPaths)
            }, completion: nil)
        }
        
        scrollToPage(page: pageNumberForDeletedPages, animated: false)
    }
}

// MARK: - Page Navigation

extension PageNavigationCollectionView {
    
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
    
    func scrollToFirstPage(animated: Bool) {
        scrollToPage(page: 0, animated: animated)
    }
    
    func scrollToLastPage(animated: Bool) {
        scrollToPage(page: numberOfPages - 1, animated: animated)
    }
    
    func scrollToPage(page: Int, animated: Bool) {
                
        scrollToPage(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: page,
                animated: animated,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil
            )
        )
    }
    
    func scrollToPage(pageNavigation: PageNavigationCollectionViewNavigationModel, completion: ((_ completed: PageNavigationCollectionViewNavigationCompleted) -> Void)? = nil) {
             
        pageNavigationCompletedClosure = completion
                            
        let pageNavigationDirectionChanged: Bool
        
        if let navigationDirection = pageNavigation.navigationDirection, navigationDirection != collectionView.semanticContentAttribute {
            
            pageNavigationDirectionChanged = true
            collectionView.semanticContentAttribute = navigationDirection
        }
        else {
    
            pageNavigationDirectionChanged = false
        }
        
        if let insertPages = pageNavigation.insertPages, !insertPages.isEmpty {
            
            let indexPaths: [IndexPath] = insertPages.map({IndexPath(item: $0, section: 0)})
            collectionView.insertItems(at: indexPaths)
        }
        
        let reloadDataNeeded: Bool = pageNavigation.reloadCollectionViewDataNeeded || pageNavigationDirectionChanged
        
        currentPageNavigation = PageNavigationCollectionView.CurrentNavigation(pageNavigation: pageNavigation, isNavigationFromDataReload: reloadDataNeeded)
                
        if reloadDataNeeded {
                                    
            collectionView.reloadData()
        }
        else {
            
            completeScrollToPageForCurrentPageNavigation(pageNavigation: pageNavigation)
        }
    }
    
    private func completeScrollToPageForCurrentPageNavigation(pageNavigation: PageNavigationCollectionViewNavigationModel) {
                
        let currentPage: Int = self.currentPage
        
        if currentPage == pageNavigation.page, let pageCell = getCellAtIndex(index: pageNavigation.page) {
                        
            let completed = PageNavigationCollectionViewNavigationCompleted(
                cancelled: false,
                pageCell: pageCell,
                pageNavigation: pageNavigation
            )
            
            navigationCompleted(completed: completed)
        }
        else {
                        
            let didScroll: Bool = internalScrollToItemOnCollectionView(item: pageNavigation.page, animated: pageNavigation.animated)
            
            if !didScroll {
                assertionFailure("\n PageNavigationCollectionView: Failed to navigate.  Should the data be reloaded?  Try setting provided pageNavigation reloadCollectionViewDataNeeded to true.  \(pageNavigation)")
                currentPageNavigation = nil
                pageNavigationCompletedClosure = nil
            }
        }
    }
    
    private func navigationCompleted(completed: PageNavigationCollectionViewNavigationCompleted) {
        
        pageNavigationCompletedClosure?(completed)
        
        currentPageNavigation = nil
        pageNavigationCompletedClosure = nil
    }
    
    private func internalScrollToItemOnCollectionView(item: Int, animated: Bool) -> Bool {
        
        guard item >= 0 && item < numberOfPages else {
            return false
        }
        
        collectionView.scrollToItem(
            at: IndexPath(item: item, section: 0),
            at: .centeredHorizontally,
            animated: animated
        )
        
        return true
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
        
        pageDidAppear(pageCell: cell, page: page)
                
        guard let currentPageNavigation = self.currentPageNavigation else {
            return
        }
        
        let didCompletePageNavigation: Bool = page == currentPageNavigation.pageNavigation.page
        
        if currentPageNavigation.isNavigationFromDataReload, currentPageNavigation.pageNavigation.page != page {
            
            completeScrollToPageForCurrentPageNavigation(pageNavigation: currentPageNavigation.pageNavigation)
        }
        
        if didCompletePageNavigation {

            let completedNavigation = PageNavigationCollectionViewNavigationCompleted(
                cancelled: false,
                pageCell: cell,
                pageNavigation: currentPageNavigation.pageNavigation
            )
            
            navigationCompleted(completed: completedNavigation)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageDidDisappear(pageCell: cell, page: indexPath.row)
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let pageWidth: CGFloat = bounds.size.width
        let pageHeight: CGFloat = bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        
        return CGSize(width: pageWidth, height: pageHeight)
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
        
        logMessage(message: "did end dragging: decelerate: \(decelerate)")
        
        if !decelerate {
            didEndPageScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        logMessage(message: "did end decelerating")
        
        didEndPageScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        logMessage(message: "did end scrolling animation")
                
        didEndPageScrolling()
        delegate?.pageNavigationDidEndScrollingAnimation?(pageNavigation: self)
    }
    
    private func didEndPageScrolling() {
        
        let currentPage: Int = self.currentPage
        
        logMessage(message: "did end page scrolling for page: \(currentPage)")
                
        if internalCurrentStoppedOnPage != currentPage {
            
            internalCurrentStoppedOnPage = currentPage
            
            let indexPath = IndexPath(item: currentPage, section: 0)
            if let pageCell = collectionView.cellForItem(at: indexPath) {
                delegate?.pageNavigationDidEndPageScrolling?(pageNavigation: self, pageCell: pageCell, page: currentPage)
            }
        }
    }
}
