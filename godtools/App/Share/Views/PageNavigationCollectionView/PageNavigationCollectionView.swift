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
    
    @objc optional func pageNavigationDidScroll(pageNavigation: PageNavigationCollectionView, page: Int)
    @objc optional func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
    @objc optional func pageNavigationDidScrollToPage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int)
}

class PageNavigationCollectionView: UIView, NibBased {
    
    private static func getDefaultFlowLayout() -> UICollectionViewFlowLayout {
        return PageNavigationCollectionViewFlowLayout()
    }
    
    struct CurrentNavigation {
        let pageNavigation: PageNavigationCollectionViewNavigationModel
        let isNavigationFromDataReload: Bool
    }
    
    private let layoutType: PageNavigationCollectionViewLayoutType
    private let initialPageIndex: Int?
    private let loggingEnabled: Bool
    
    private var layout: UICollectionViewFlowLayout = PageNavigationCollectionView.getDefaultFlowLayout()
    private var currentPageNavigation: PageNavigationCollectionView.CurrentNavigation?
    private var pendingPageNavigationForPagesDidLoad: PageNavigationCollectionViewNavigationModel?
    private var pendingPageNavigationCompletionForPagesDidLoad: ((_ completed: PageNavigationCollectionViewNavigationCompleted) -> Void)?
    private var pageNavigationCompletedClosure: ((_ completed: PageNavigationCollectionViewNavigationCompleted) -> Void)?
    private var internalCurrentChangedPage: Int = -1
    private var internalCurrentStoppedOnPage: Int = -1
    private var didLayoutSubviews: Bool = false
    private var didLoadPages: Bool = false
    
    @IBOutlet weak private var collectionView: UICollectionView!
    
    private weak var delegate: PageNavigationCollectionViewDelegate?
    
    init(layoutType: PageNavigationCollectionViewLayoutType = .fullScreen, initialPageIndex: Int?, loggingEnabled: Bool = false) {
        
        self.layoutType = layoutType
        self.initialPageIndex = initialPageIndex
        self.loggingEnabled = loggingEnabled
        
        super.init(frame: UIScreen.main.bounds)
        
        switch layoutType {
        case .centeredRevealingPreviousAndNextPage( _):
            self.layout = PageNavigationCollectionViewCenteredLayout(layoutType: layoutType, pageNavigationCollectionView: self)
            
        case .fullScreen:
            self.layout = PageNavigationCollectionView.getDefaultFlowLayout()
        }
        
        initialize()
    }
    
    override init(frame: CGRect) {
        
        assertionFailure("init(frame:) not supported")
        
        self.layout = PageNavigationCollectionView.getDefaultFlowLayout()
        self.layoutType = .fullScreen
        self.initialPageIndex = nil
        self.loggingEnabled = false
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        
        self.layout = PageNavigationCollectionView.getDefaultFlowLayout()
        self.layoutType = .fullScreen
        self.initialPageIndex = nil
        self.loggingEnabled = false
        
        super.init(coder: coder)
        
        initialize()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initialize() {
        
        loadNib()
        setupLayout()
                        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func setupLayout() {
                
        layout.scrollDirection = .horizontal

        collectionView.collectionViewLayout = layout
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = .zero
        
        switch layoutType {
        case .centeredRevealingPreviousAndNextPage( _):
            collectionView.isPagingEnabled = false
        case .fullScreen:
            collectionView.isPagingEnabled = true
        }
        
        if #available(iOS 16, *) {
            collectionView.selfSizingInvalidation = .disabled
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didLayoutSubviews = true
        
        if getNumberOfPages() > 0 && !didLoadPages {
            didLoadPages = true
            handleLoadPagesCompleted()
        }
    }
    
    private func handleLoadPagesCompleted() {
        
        logMessage(message: "handleLoadPagesCompleted()")
        
        if let pageNavigation = pendingPageNavigationForPagesDidLoad {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToPage(pageNavigation: pageNavigation, completion: self?.pendingPageNavigationCompletionForPagesDidLoad)
            }
        }
        else if let initialPageIndex = initialPageIndex {
            DispatchQueue.main.async { [weak self] in
                self?.scrollToPage(page: initialPageIndex, animated: false)
            }
        }
    }
    
    // MARK: -
    
    func setDelegate(delegate: PageNavigationCollectionViewDelegate?) {
        self.delegate = delegate
    }
    
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
        
        let currentPage: Int = getCurrentPage()
        
        return collectionView.cellForItem(at: IndexPath(item: currentPage, section: 0))
    }
    
    var isOnFirstPage: Bool {
        return getCurrentPage() == 0
    }
    
    var isOnLastPage: Bool {
        let numberOfPages: Int = getNumberOfPages()
        return getCurrentPage() >= numberOfPages - 1 && numberOfPages > 0
    }
    
    func setPagingEnabled(pagingEnabled: Bool) {
        collectionView.isPagingEnabled = pagingEnabled
    }
    
    func setContentInset(contentInset: UIEdgeInsets) {
        
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage( _):
            return
            
        case .fullScreen:
            break
        }
        
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

    func getPageSize() -> CGSize {
        
        let pageWidth: CGFloat
        let pageHeight: CGFloat
        
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage(let pageLayoutAttributes):
            pageWidth = bounds.size.width - ((pageLayoutAttributes.spacingBetweenPages + pageLayoutAttributes.pageWidthAmountToRevealForPreviousAndNextPage) * 2)
            pageHeight = floor((pageWidth / pageLayoutAttributes.cardAspectRatio.width) * pageLayoutAttributes.cardAspectRatio.height)
            
        case .fullScreen:
            pageWidth = bounds.size.width
            pageHeight = bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        }
        
        return CGSize(width: pageWidth, height: pageHeight)
    }
    
    func getPageSpacing() -> CGFloat {
        
        let pageSpacing: CGFloat
        
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage(let pageLayoutAttributes):
            pageSpacing = pageLayoutAttributes.spacingBetweenPages
            
        case .fullScreen:
            pageSpacing = 0
        }
        
        return pageSpacing
    }
    
    func getPreviousAndNextPageRevealAmount() -> CGFloat {
        
        let revealAmount: CGFloat
        
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage(let pageLayoutAttributes):
            revealAmount = pageLayoutAttributes.pageWidthAmountToRevealForPreviousAndNextPage
            
        case .fullScreen:
            revealAmount = 0
        }
        
        return revealAmount
    }
    
    func getNumberOfPages() -> Int {
        
        guard collectionView != nil else {
            return 0
        }
        
        return collectionView.numberOfItems(inSection: 0)
    }

    func getCurrentPage() -> Int {
        return getPageBasedOnContentOffset(contentOffset: collectionView.contentOffset)
    }
    
    func getPageBasedOnContentOffset(contentOffset: CGPoint) -> Int {
                
        let numberOfPages: Int = getNumberOfPages()
        
        guard numberOfPages > 0 else {
            return 0
        }
        
        let contentOffsetX: CGFloat = abs(contentOffset.x)
        
        let pageInterval: CGFloat = getPageSize().width + getPageSpacing()
            
        let pageFloatValue: CGFloat = contentOffsetX / pageInterval
        let minPage: CGFloat = floor(pageFloatValue)
        let maxPage: CGFloat = ceil(pageFloatValue)
                
        let page: Int
        
        if (pageFloatValue - minPage) < (maxPage - pageFloatValue) {
            page = Int(minPage)
        }
        else {
            page = Int(maxPage)
        }
        
        logMessage(message: "getPageBasedOnContentOffset()")
        logMessage(message: "  contentOffset: \(contentOffset.x)", includeClassNameHeader: false)
        logMessage(message: "  numberOfPages: \(numberOfPages)", includeClassNameHeader: false)
        logMessage(message: "  page: \(page)", includeClassNameHeader: false)
        
        return page
    }
    
    func getPageContentOffset(page: Int) -> CGPoint {
        
        let pageInterval: CGFloat
        
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage(let pageLayoutAttributes):
    
            let pageWidth: CGFloat = bounds.size.width - ((pageLayoutAttributes.spacingBetweenPages + pageLayoutAttributes.pageWidthAmountToRevealForPreviousAndNextPage) * 2)
            pageInterval = pageWidth + pageLayoutAttributes.spacingBetweenPages
            
        case .fullScreen:
            pageInterval = bounds.size.width
        }
        
        let offsetX: CGFloat = pageInterval * CGFloat(page)
        
        return CGPoint(x: offsetX, y: 0)
    }
    
    func getHorizontalInset() -> CGFloat {
        
        let horizontalInset: CGFloat
        
        switch layoutType {
            
        case .centeredRevealingPreviousAndNextPage(let pageLayoutAttributes):
            
            horizontalInset = pageLayoutAttributes.spacingBetweenPages + pageLayoutAttributes.pageWidthAmountToRevealForPreviousAndNextPage
            
        case .fullScreen:
            horizontalInset = 0
        }
        
        return horizontalInset
    }
    
    private func logMessage(message: String, includeClassNameHeader: Bool = true) {
        
        guard loggingEnabled else {
            return
        }
        
        if includeClassNameHeader {
            print("\n PageNavigationCollectionView: \(message)")
        }
        else {
            print(message)
        }
    }
}

// MARK: - Page Life Cycle

extension PageNavigationCollectionView {
    
    private func mostVisiblePageChanged(pageCell: UICollectionViewCell, page: Int) {
        
        guard getNumberOfPages() > 0 else {
            return
        }
        
        logMessage(message: "most visible page changed: \(page)")
        
        delegate?.pageNavigationDidChangeMostVisiblePage?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidAppear(pageCell: UICollectionViewCell, page: Int) {
        
        guard getNumberOfPages() > 0 else {
            return
        }
        
        logMessage(message: "page did appear: \(page)")
        
        delegate?.pageNavigationPageDidAppear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func pageDidDisappear(pageCell: UICollectionViewCell, page: Int) {
        
        guard getNumberOfPages() > 0 else {
            return
        }
        
        logMessage(message: "page did disappear: \(page)")
        
        delegate?.pageNavigationPageDidDisappear?(pageNavigation: self, pageCell: pageCell, page: page)
    }
    
    private func didScroll(page: Int) {
        
        guard getNumberOfPages() > 0 else {
            return
        }
        
        delegate?.pageNavigationDidScroll?(pageNavigation: self, page: page)
    }
    
    private func didScrollToPage(pageCell: UICollectionViewCell, page: Int) {
        
        guard getNumberOfPages() > 0 else {
            return
        }
        
        logMessage(message: "did scroll to page: \(getCurrentPage())")
        
        // NOTE: I did notice this method will not get called when performing a navigation where pages are deleted because UIScrollView delegate method scrollViewDidEndScrollingAnimation is never called. ~Levi
        
        delegate?.pageNavigationDidScrollToPage?(pageNavigation: self, pageCell: pageCell, page: page)
    }
}

// MARK: - Page Navigation

extension PageNavigationCollectionView {
    
    func scrollToPreviousPage(animated: Bool) {
        if !isOnFirstPage {
            scrollToPage(page: getCurrentPage() - 1, animated: animated)
        }
    }
    
    func scrollToNextPage(animated: Bool) {
        if !isOnLastPage {
            scrollToPage(page: getCurrentPage() + 1, animated: animated)
        }
    }
    
    func scrollToFirstPage(animated: Bool) {
        scrollToPage(page: 0, animated: animated)
    }
    
    func scrollToLastPage(animated: Bool) {
        scrollToPage(page: getNumberOfPages() - 1, animated: animated)
    }
    
    func scrollToPage(page: Int, animated: Bool) {
                
        scrollToPage(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: page,
                animated: animated,
                reloadCollectionViewDataNeeded: false,
                insertPages: nil,
                deletePages: nil
            )
        )
    }
    
    func scrollToPage(pageNavigation: PageNavigationCollectionViewNavigationModel, completion: ((_ completed: PageNavigationCollectionViewNavigationCompleted) -> Void)? = nil) {
             
        guard didLoadPages else {
            pendingPageNavigationForPagesDidLoad = pageNavigation
            pendingPageNavigationCompletionForPagesDidLoad = completion
            return
        }
        
        let isPendingNavigation: Bool = pendingPageNavigationForPagesDidLoad != nil
        let shouldIgnoreBatchUpdates: Bool = isPendingNavigation
        let shouldNotAnimate: Bool = isPendingNavigation
        
        pendingPageNavigationForPagesDidLoad = nil
        pendingPageNavigationCompletionForPagesDidLoad = nil
        
        logMessage(message: "scrollToPage for pageNavigation \(pageNavigation)")
        logMessage(message: "  did load pages: \(didLoadPages)", includeClassNameHeader: false)
        logMessage(message: "  scroll to page for pageNavigation number of pages: \(getNumberOfPages())", includeClassNameHeader: false)
        
        pageNavigationCompletedClosure = completion
                            
        let pageNavigationDirectionChanged: Bool
        
        if let navigationDirection = pageNavigation.navigationDirection, navigationDirection != collectionView.semanticContentAttribute {
            
            pageNavigationDirectionChanged = true
            setSemanticContentAttribute(semanticContentAttribute: navigationDirection)
        }
        else {
    
            pageNavigationDirectionChanged = false
        }
        
        let reloadDataNeeded: Bool = pageNavigation.reloadCollectionViewDataNeeded || pageNavigationDirectionChanged
        
        if !reloadDataNeeded && !shouldIgnoreBatchUpdates {
         
            collectionView.performBatchUpdates {
                
                if let deletePages = pageNavigation.deletePages, !deletePages.isEmpty {
                    
                    let indexPaths: [IndexPath] = deletePages.map({IndexPath(item: $0, section: 0)})
                    collectionView.deleteItems(at: indexPaths)
                    
                    logMessage(message: "  delete pages: \(deletePages)", includeClassNameHeader: false)
                }
                
                if let insertPages = pageNavigation.insertPages, !insertPages.isEmpty {
                    
                    let indexPaths: [IndexPath] = insertPages.map({IndexPath(item: $0, section: 0)})
                    collectionView.insertItems(at: indexPaths)
                    
                    logMessage(message: "  insert pages: \(insertPages)", includeClassNameHeader: false)
                }
            }
        }
        
        currentPageNavigation = PageNavigationCollectionView.CurrentNavigation(
            pageNavigation: pageNavigation,
            isNavigationFromDataReload: reloadDataNeeded
        )
                
        if reloadDataNeeded {
            
            logMessage(message: "  will reload data", includeClassNameHeader: false)
            
            collectionView.reloadData()
        }
        else {
            
            logMessage(message: "  will complete scroll to page", includeClassNameHeader: false)
            logMessage(message: "  pageNavigation.page: \(pageNavigation.page)", includeClassNameHeader: false)
            logMessage(message: "  number of pages: \(getNumberOfPages())", includeClassNameHeader: false)
            
            completeScrollToPageForCurrentPageNavigation(pageNavigation: pageNavigation, shouldNotAnimate: shouldNotAnimate)
        }
    }
    
    private func completeScrollToPageForCurrentPageNavigation(pageNavigation: PageNavigationCollectionViewNavigationModel, shouldNotAnimate: Bool = false) {
                
        let currentPage: Int = getCurrentPage()
        
        logMessage(message: "completeScrollToPageForCurrentPageNavigation()")
        logMessage(message: "  currentPage: \(currentPage)", includeClassNameHeader: false)
        logMessage(message: "  pageNavigation.page: \(pageNavigation.page)", includeClassNameHeader: false)
        
        if currentPage == pageNavigation.page, let pageCell = getCellAtIndex(index: pageNavigation.page) {
                     
            logMessage(message: "  pageCell exists: true", includeClassNameHeader: false)
            
            let completed = PageNavigationCollectionViewNavigationCompleted(
                cancelled: false,
                pageCell: pageCell,
                pageNavigation: pageNavigation
            )
            
            navigationCompleted(completed: completed)
        }
        else {
            
            let animated: Bool = !shouldNotAnimate ? pageNavigation.animated : false
            let didScroll: Bool = internalScrollToItemOnCollectionView(item: pageNavigation.page, animated: animated)
            
            logMessage(message: "  internal scroll to item: \(pageNavigation.page)", includeClassNameHeader: false)
            logMessage(message: "    animated: \(animated)", includeClassNameHeader: false)
            logMessage(message: "    didScroll: \(didScroll)", includeClassNameHeader: false)
            
            if !didScroll && animated == true {
                assertionFailure("\n PageNavigationCollectionView: Failed to navigate.  Should the data be reloaded?  Try setting provided pageNavigation reloadCollectionViewDataNeeded to true.  \(pageNavigation)")
                currentPageNavigation = nil
                pageNavigationCompletedClosure = nil
            }
        }
    }
    
    private func navigationCompleted(completed: PageNavigationCollectionViewNavigationCompleted) {
        
        logMessage(message: "scrollToPage for pageNavigation completed \(completed)")
        
        if !completed.pageNavigation.animated {
            
            mostVisiblePageChanged(pageCell: completed.pageCell, page: completed.pageNavigation.page)
            didScrollToPage(pageCell: completed.pageCell, page: completed.pageNavigation.page)
        }
        
        pageNavigationCompletedClosure?(completed)
        
        currentPageNavigation = nil
        pageNavigationCompletedClosure = nil
    }
    
    private func internalScrollToItemOnCollectionView(item: Int, animated: Bool) -> Bool {
        
        guard item >= 0 && item < getNumberOfPages() else {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                
        switch layoutType {
        
        case .centeredRevealingPreviousAndNextPage( _):
           
            let currentPage: Int = getCurrentPage()
                        
            if indexPath.row != currentPage {
                scrollToPage(page: indexPath.row, animated: true)
            }
            
        case .fullScreen:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numberOfItems: Int = delegate?.pageNavigationNumberOfPages(pageNavigation: self) ?? 0
        
        logMessage(message: "number of items: \(numberOfItems)")
        
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let cell: UICollectionViewCell? = delegate?.pageNavigation(pageNavigation: self, cellForPageAt: indexPath)
        
        cell?.backgroundColor = pageBackgroundColor
        cell?.contentView.backgroundColor = pageBackgroundColor
                
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
                
        let page: Int = indexPath.row
        
        logMessage(message: "cell for item: \(page)")
        
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
        let pageSize: CGSize = getPageSize()
        
        logMessage(message: "page size \(pageSize) for item: \(indexPath.row)")
        
        return pageSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return getPageSpacing()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let horizontalInset: CGFloat = getHorizontalInset()
        
        let edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        
        return edgeInsets
    }
}

// MARK: - UIScrollViewDelegate

extension PageNavigationCollectionView: UIScrollViewDelegate {
     
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
                        
        // logMessage(message: "did scroll")
        // logMessage(message: "  contentOffset.x: \(scrollView.contentOffset.x)", includeClassNameHeader: false)
        
        let currentPage: Int = getPageBasedOnContentOffset(contentOffset: scrollView.contentOffset)
                
        didScroll(page: currentPage)
                
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
        logMessage(message: "  contentOffset.x: \(scrollView.contentOffset.x)", includeClassNameHeader: false)
        
        if !decelerate {
            didEndPageScrolling()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        logMessage(message: "did end decelerating")
        logMessage(message: "  contentOffset.x: \(scrollView.contentOffset.x)", includeClassNameHeader: false)
        
        didEndPageScrolling()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        logMessage(message: "did end scrolling animation")
                
        didEndPageScrolling()
    }
    
    private func didEndPageScrolling() {
        
        let currentPage: Int = getCurrentPage()
        
        logMessage(message: "did end page scrolling for page: \(currentPage)")
        logMessage(message: "   contentOffset.x: \(collectionView.contentOffset.x)", includeClassNameHeader: false)
        logMessage(message: "   internalCurrentStoppedOnPage: \(internalCurrentStoppedOnPage)", includeClassNameHeader: false)
        logMessage(message: "   currentPage: \(currentPage)", includeClassNameHeader: false)
                
        if internalCurrentStoppedOnPage != currentPage {
            
            internalCurrentStoppedOnPage = currentPage
            
            let indexPath = IndexPath(item: currentPage, section: 0)
            if let pageCell = collectionView.cellForItem(at: indexPath) {
                didScrollToPage(pageCell: pageCell, page: currentPage)
            }
        }
    }
}
