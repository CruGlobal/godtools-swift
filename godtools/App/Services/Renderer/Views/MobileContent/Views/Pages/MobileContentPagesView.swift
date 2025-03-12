//
//  MobileContentPagesView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPagesView: AppViewController {
    
    typealias PageNumber = Int
    
    private let viewModel: MobileContentPagesViewModel
    
    private var initialPagePositions: [PageNumber: MobileContentViewPositionState] = Dictionary()
    private var pageInsets: UIEdgeInsets = .zero
    private var currentNavigationEvent: MobileContentPagesNavigationEvent?
    private var didLayoutSubviews: Bool = false
          
    private weak var pageViewDelegate: MobileContentPageViewDelegate?
    
    @IBOutlet weak private(set) var safeAreaView: UIView!
    
    let pageNavigationView: PageNavigationCollectionView
        
    init(viewModel: MobileContentPagesViewModel, navigationBar: AppNavigationBar?, pageViewDelegate: MobileContentPageViewDelegate?, initialPageIndex: Int?, loggingEnabled: Bool = false) {
        
        self.viewModel = viewModel
        self.pageNavigationView = PageNavigationCollectionView(layoutType: .fullScreen, initialPageIndex: initialPageIndex, loggingEnabled: loggingEnabled)
        self.pageViewDelegate = pageViewDelegate
        
        super.init(nibName: String(describing: MobileContentPagesView.self), bundle: nil, navigationBar: navigationBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
                        
        var safeAreaTopInset: CGFloat = view.safeAreaInsets.top
        let safeAreaBottomInset: CGFloat = view.safeAreaInsets.bottom
        
        if safeAreaTopInset == 0 {
            safeAreaTopInset = safeAreaView.convert(.zero, to: nil).y
        }
        
        let safeArea: UIEdgeInsets = UIEdgeInsets(
            top: safeAreaTopInset + pageInsets.top,
            left: 0,
            bottom: safeAreaBottomInset + pageInsets.bottom,
            right: 0
        )
        
        pageNavigationView.setDelegate(delegate: self)
        
        viewModel.viewDidFinishLayout(
            window: navigationController ?? self,
            safeArea: safeArea
        )
    }
    
    func setupLayout() {
                       
        // pageNavigationView
        view.addSubview(pageNavigationView)
        pageNavigationView.translatesAutoresizingMaskIntoConstraints = false
        pageNavigationView.constrainEdgesToView(view: view)
        
        pageNavigationView.setSemanticContentAttribute(semanticContentAttribute: viewModel.layoutDirection)
        
        pageNavigationView.pageBackgroundColor = .clear
        pageNavigationView.registerPageCell(
            nib: UINib(nibName: MobileContentPageCell.nibName, bundle: nil),
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier
        )
        pageNavigationView.setContentInset(contentInset: .zero)
        pageNavigationView.setContentInsetAdjustmentBehavior(contentInsetAdjustmentBehavior: .never)
    }
    
    func setupBinding() {

        viewModel.pageNavigationEventSignal.addObserver(self) { [weak self] (navigationEvent: MobileContentPagesNavigationEvent) in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.currentNavigationEvent = navigationEvent
                        
            weakSelf.pageNavigationView.scrollToPage(pageNavigation: navigationEvent.pageNavigation, completion: { (completedNavigation: PageNavigationCollectionViewNavigationCompleted) in
                                    
                if let pagePositions = navigationEvent.pagePositions, let pageCell = completedNavigation.pageCell as? MobileContentPageCell, let pageView = pageCell.mobileContentView as? MobileContentPageView {
                    
                    pageView.setPositionStateForViewHierarchy(
                        positionState: pagePositions,
                        animated: completedNavigation.pageNavigation.animated
                    )
                }
                
                weakSelf.currentNavigationEvent = nil
            })
        }
    }
    
    func setPageViewDelegate(pageViewDelegate: MobileContentPageViewDelegate?) {

        self.pageViewDelegate = pageViewDelegate
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
            
            if let pageCell = cell as? MobileContentPageCell, let pageView = pageCell.mobileContentView as? MobileContentPageView, let indexPath = pageNavigationView.getIndexPathForPageCell(pageCell: pageCell) {
                
                let page: Int = indexPath.row
                let currentPagePositions: MobileContentViewPositionState = pageView.getPositionStateForViewHierarchy()
                
                pagePositions[page] = currentPagePositions
            }
        }
        
        return pagePositions
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
    
    func setCurrentPagePositions(pagePositions: MobileContentViewPositionState, animated: Bool) {
        
        guard let pageCell = pageNavigationView.currentPageCell as? MobileContentPageCell else {
            return
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return
        }
        
        pageView.setPositionStateForViewHierarchy(positionState: pagePositions, animated: animated)
    }
    
    func clearInitialPagePositions() {
        initialPagePositions.removeAll()
    }
    
    func resetInitialPagePositionsToAllVisiblePagePositions() {
        initialPagePositions = getAllVisiblePagesPositions()
    }
    
    func navigateToPage(pageIndex: Int, animated: Bool) {
        
        viewModel.navigateToPage(pageIndex: pageIndex, animated: animated)
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension MobileContentPagesView: PageNavigationCollectionViewDelegate {
        
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        
        return viewModel.getNumberOfPages()
    }
    
    func pageNavigation(pageNavigation: PageNavigationCollectionView, cellForPageAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = pageNavigationView.getReusablePageCell(
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier,
            indexPath: indexPath) as? MobileContentPageCell else {
            
            assertionFailure("Failed to dequeue reusable cell with identifier :\(MobileContentPageCell.reuseIdentifier)")
            
            return UICollectionViewCell()
        }
        
        let pageNumber: Int = indexPath.row
        
        guard let pageView = viewModel.pageWillAppear(page: pageNumber) as? MobileContentPageView else {
            assertionFailure("Provided MobileContentView should inherit from MobileContentPageView")
            return UICollectionViewCell()
        }
        
        cell.configure(mobileContentView: pageView)
        
        pageView.setPageViewDelegate(pageViewDelegate: self)
        
        pageView.setSemanticContentAttribute(semanticContentAttribute: viewModel.layoutDirection)
        
        didConfigurePageView(pageView: pageView)
                        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        view.endEditing(true)
        
        viewModel.didChangeMostVisiblePage(page: page)
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
    
    func pageNavigationDidScrollToPage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        viewModel.didScrollToPage(page: page)
    }
}

// MARK: - MobileContentPageViewDelegate

extension MobileContentPagesView: MobileContentPageViewDelegate {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult? {
        
        _ = pageViewDelegate?.pageViewDidReceiveEvent(pageView: pageView, eventId: eventId)
        
        return viewModel.pageDidReceiveEvent(eventId: eventId)
    }
}
