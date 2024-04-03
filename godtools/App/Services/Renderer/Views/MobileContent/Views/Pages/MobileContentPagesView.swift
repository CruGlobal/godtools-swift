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
    private var didLayoutSubviews: Bool = false
          
    @IBOutlet weak private(set) var safeAreaView: UIView!
    
    let pageNavigationView: PageNavigationCollectionView
        
    init(viewModel: MobileContentPagesViewModel, navigationBar: AppNavigationBar?) {
        
        self.viewModel = viewModel
        self.pageNavigationView = PageNavigationCollectionView(layoutType: .fullScreen)
        
        super.init(nibName: String(describing: MobileContentPagesView.self), bundle: nil, navigationBar: navigationBar)
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

        viewModel.rendererWillChangeSignal.addObserver(self) { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.initialPagePositions.removeAll()
            weakSelf.initialPagePositions = weakSelf.getAllVisiblePagesPositions()
        }
        
        viewModel.pageNavigationEventSignal.addObserver(self) { [weak self] (navigationEvent: MobileContentPagesNavigationEvent) in
            
            guard let weakSelf = self else {
                return
            }
                        
            weakSelf.pageNavigationView.scrollToPage(pageNavigation: navigationEvent.pageNavigation, completion: { (completedNavigation: PageNavigationCollectionViewNavigationCompleted) in
                                    
                if let pagePositions = navigationEvent.pagePositions,
                   let pageCell = completedNavigation.pageCell as? MobileContentPageCell,
                   let pageView = pageCell.mobileContentView as? MobileContentPageView {
                    
                    pageView.setPositionStateForViewHierarchy(
                        positionState: pagePositions,
                        animated: completedNavigation.pageNavigation.animated
                    )
                }
            })
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
}

// MARK: - MobileContentPageViewDelegate

extension MobileContentPagesView: MobileContentPageViewDelegate {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult? {
        return viewModel.pageDidReceiveEvent(eventId: eventId)
    }
}
