//
//  MobileContentPagesView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPagesView: UIViewController {
    
    typealias PageNumber = Int
    
    private let viewModel: MobileContentPagesViewModel
    
    private var initialPagePositions: [PageNumber: MobileContentViewPositionState] = Dictionary()
    private var completeNavigationEventForDataReload: MobileContentPagesNavigationEvent?
    private var completePagePositionsAfterScrollToPage: MobileContentPagesNavigationEvent?
    private var pageInsets: UIEdgeInsets = .zero
    private var didLayoutSubviews: Bool = false
          
    @IBOutlet weak private(set) var safeAreaView: UIView!
    @IBOutlet weak private(set) var pageNavigationView: PageNavigationCollectionView!
        
    init(viewModel: MobileContentPagesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: MobileContentPagesView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
        
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
                
        var safeAreaTopInset: CGFloat
        let safeAreaBottomInset: CGFloat
        
        if #available(iOS 11.0, *) {
            safeAreaTopInset = view.safeAreaInsets.top
            safeAreaBottomInset = view.safeAreaInsets.bottom
        } else {
            safeAreaTopInset = topLayoutGuide.length
            safeAreaBottomInset = bottomLayoutGuide.length
        }
        
        if safeAreaTopInset == 0 {
            safeAreaTopInset = safeAreaView.convert(.zero, to: nil).y
        }
        
        let safeArea: UIEdgeInsets = UIEdgeInsets(
            top: safeAreaTopInset + pageInsets.top,
            left: 0,
            bottom: safeAreaBottomInset + pageInsets.bottom,
            right: 0
        )
        
        pageNavigationView.delegate = self
        
        viewModel.viewDidFinishLayout(
            window: navigationController ?? self,
            safeArea: safeArea
        )
    }
    
    func setupLayout() {
                       
        // pageNavigationView
        pageNavigationView.pageBackgroundColor = .clear
        pageNavigationView.registerPageCell(
            nib: UINib(nibName: MobileContentPageCell.nibName, bundle: nil),
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier
        )
        pageNavigationView.setContentInset(contentInset: .zero)
        pageNavigationView.setContentInsetAdjustmentBehavior(contentInsetAdjustmentBehavior: .never)
    }
    
    func setupBinding() {
        
        viewModel.reRendererPagesSignal.addObserver(self) { [weak self] (reRenderPagesModel: MobileContentPagesReRenderPagesModel) in
                        
            guard let weakSelf = self else {
                return
            }
            
            if let pagesSemanticContentAttribute = reRenderPagesModel.pagesSemanticContentAttribute {
                weakSelf.pageNavigationView.setSemanticContentAttribute(semanticContentAttribute: pagesSemanticContentAttribute)
            }
                  
            weakSelf.completeNavigationEventForDataReload = nil
            weakSelf.completePagePositionsAfterScrollToPage = nil
            weakSelf.initialPagePositions.removeAll()
            weakSelf.initialPagePositions = weakSelf.getAllVisiblePagesPositions()
            weakSelf.pageNavigationView.cancelScroll()
            
            weakSelf.completeNavigationEventForDataReload = reRenderPagesModel.pageNavigation
            weakSelf.completePagePositionsAfterScrollToPage = reRenderPagesModel.pageNavigation
            weakSelf.pageNavigationView.reloadData()
        }
        
        viewModel.navigatePageSignal.addObserver(self) { [weak self] (event: MobileContentPagesNavigationEvent) in
            
            guard let weakSelf = self else {
                return
            }
            
            let currentPage: Int = weakSelf.pageNavigationView.currentPage
            
            if event.reloadPagesCollectionViewNeeded {
                
                weakSelf.completeNavigationEventForDataReload = nil
                weakSelf.completePagePositionsAfterScrollToPage = nil
                weakSelf.pageNavigationView.cancelScroll()
                
                weakSelf.completeNavigationEventForDataReload = event
                weakSelf.completePagePositionsAfterScrollToPage = event
                weakSelf.pageNavigationView.reloadData()
            }
            else if currentPage != event.page {
                
                weakSelf.completeNavigationEventForDataReload = nil
                weakSelf.completePagePositionsAfterScrollToPage = nil
                weakSelf.pageNavigationView.cancelScroll()
                
                weakSelf.completePagePositionsAfterScrollToPage = event
                weakSelf.pageNavigationView.scrollToPage(page: event.page, animated: event.animated)
            }
            else if currentPage == event.page, let pagePositions = event.pagePositions, let pageView = weakSelf.getPageView(page: event.page) {
                
                weakSelf.completeNavigationEventForDataReload = nil
                weakSelf.completePagePositionsAfterScrollToPage = nil
                pageView.setPositionStateForViewHierarchy(positionState: pagePositions, animated: event.animated)
            }
        }
        
        viewModel.pagesRemovedSignal.addObserver(self) { [weak self] (indexPaths: [IndexPath]) in
            
            guard !indexPaths.isEmpty else {
                return
            }
            
            self?.pageNavigationView.deletePagesAt(indexPaths: indexPaths)
        }
    }
    
    func didConfigurePageView(pageView: MobileContentPageView) {
        
    }
    
    func setPageInsets(pageInsets: UIEdgeInsets) {
        
        if didLayoutSubviews {
            assertionFailure("Set pageInsets before views are laid out.  Best place to set is on initialization or viewDidLoad.")
            return
        }
        
        self.pageInsets = pageInsets
    }
    
    private func getAllVisiblePagesPositions() -> [PageNumber: MobileContentViewPositionState] {
                        
        var pagePositions: [PageNumber: MobileContentViewPositionState] = Dictionary()
        
        let visiblePageCells: [UICollectionViewCell] = pageNavigationView.getVisiblePageCells()
        
        for cell in visiblePageCells {
            
            if let pageCell = cell as? MobileContentPageCell,
               let pageView = pageCell.mobileContentView as? MobileContentPageView,
               let indexPath = pageNavigationView.getIndexPathForPageCell(pageCell: pageCell) {
                
                let page: Int = indexPath.row
                let currentPagePositions: MobileContentViewPositionState = pageView.getPositionStateForViewHierarchy()
                
                pagePositions[page] = currentPagePositions
            }
        }
        
        return pagePositions
    }
    
    private func getPageView(page: Int) -> MobileContentPageView? {
        
        guard let pageCell = pageNavigationView.getCellForItem(indexPath: IndexPath(item: page, section: 0)) as? MobileContentPageCell else {
            return nil
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return nil
        }
        
        return pageView
    }
    
    func getPagePositions(page: Int) -> MobileContentViewPositionState? {
        
        guard let pageCell = pageNavigationView.getCellForItem(indexPath: IndexPath(item: page, section: 0)) as? MobileContentPageCell else {
            return nil
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return nil
        }
        
        return pageView.getPositionStateForViewHierarchy()
    }
    
    func getCurrentPagePositions() -> MobileContentViewPositionState? {
                
        guard let pageCell = pageNavigationView.currentPageCell as? MobileContentPageCell else {
            return nil
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return nil
        }
        
        return pageView.getPositionStateForViewHierarchy()
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension MobileContentPagesView: PageNavigationCollectionViewDelegate {
        
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        
        return viewModel.getNumberOfRenderedPages()
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: MobileContentPageCell = pageNavigationView.getReusablePageCell(
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier,
            indexPath: indexPath) as! MobileContentPageCell
        
        let pageNumber: Int = indexPath.row
        
        guard let pageView = viewModel.pageWillAppear(page: pageNumber) as? MobileContentPageView else {
            assertionFailure("Provided MobileContentView should inherit from MobileContentPageView")
            return UICollectionViewCell()
        }
        
        cell.configure(mobileContentView: pageView)
        
        pageView.setDelegate(delegate: self)
        
        didConfigurePageView(pageView: pageView)
                
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        view.endEditing(true)
        
        viewModel.didChangeMostVisiblePage(page: page)
    }
    
    func pageNavigationPageWillAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        if let contentPageCell = pageCell as? MobileContentPageCell {
            
            if let pageView = contentPageCell.mobileContentView as? MobileContentPageView, let pagePositions = initialPagePositions[page] {
                
                pageView.layoutIfNeeded()
                pageView.setPositionStateForViewHierarchy(positionState: pagePositions, animated: false)
                initialPagePositions[page] = nil
            }
            
            contentPageCell.mobileContentView?.notifyViewAndAllChildrenViewDidAppear()
        }
                
        viewModel.pageDidAppear(page: page)
    }
    
    func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                        
        if let contentPageCell = pageCell as? MobileContentPageCell {
            contentPageCell.mobileContentView?.notifyViewAndAllChildrenViewDidDisappear()
        }
        
        viewModel.pageDidDisappear(page: page)
    }
    
    func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
    
    func pageNavigationDidEndPageScrolling(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        print("\n ------> DID END PAGE SCROLLING")
        print("  page: \(page)")
        print("  ")
        
        var isScrollingToNewPage: Bool = false
        
        if let eventForDataReload = completeNavigationEventForDataReload {
            
            self.completeNavigationEventForDataReload = nil
            
            if page != eventForDataReload.page {
                isScrollingToNewPage = true
                pageNavigationView.scrollToPage(page: eventForDataReload.page, animated: eventForDataReload.animated)
            }
        }
                
        if let eventForScrollToPageEnded = completePagePositionsAfterScrollToPage {

            self.completePagePositionsAfterScrollToPage = nil
            
            if page == eventForScrollToPageEnded.page, let pagePositions = eventForScrollToPageEnded.pagePositions, let pageView = getPageView(page: page) {
                
                pageView.setPositionStateForViewHierarchy(positionState: pagePositions, animated: eventForScrollToPageEnded.animated)
            }
        }
        
        if !isScrollingToNewPage {
            viewModel.didEndPageScrolling(page: page)
        }
    }
}

// MARK: - MobileContentPageViewDelegate

extension MobileContentPagesView: MobileContentPageViewDelegate {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult? {
        return viewModel.pageDidReceiveEvent(eventId: eventId)
    }
}
