//
//  MobileContentPagesView.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentPagesView: UIViewController {
    
    typealias PageNumber = Int
    
    private let viewModel: MobileContentPagesViewModelType
    
    private var initialPagePositions: [PageNumber: MobileContentPagePositionsType] = Dictionary()
    private var currentNavigation: MobileContentPagesNavigationModel?
    private var pageInsets: UIEdgeInsets = .zero
    private var didLayoutSubviews: Bool = false
          
    @IBOutlet weak private(set) var safeAreaView: UIView!
    @IBOutlet weak private(set) var pageNavigationView: PageNavigationCollectionView!
        
    required init(viewModel: MobileContentPagesViewModelType) {
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
        
        viewModel.viewDidFinishLayout(
            window: navigationController ?? self,
            safeArea: safeArea
        )

        pageNavigationView.delegate = self
        
        viewModel.numberOfPages.addObserver(self) { [weak self] (numberOfToolPages: Int) in
            self?.pageNavigationView.reloadData()
        }
        
        viewModel.pageNavigation.addObserver(self) { [weak self] (navigationModel: MobileContentPagesNavigationModel?) in
            if let navigationModel = navigationModel {
                self?.startNavigation(navigationModel: navigationModel)
            }
        }
        
        viewModel.pagesRemoved.addObserver(self) { [weak self] (indexPaths: [IndexPath]) in
            guard !indexPaths.isEmpty else {
                return
            }
            self?.pageNavigationView.deletePagesAt(indexPaths: indexPaths)
        }
    }
    
    func setupLayout() {
               
        navigationController?.navigationBar.isTranslucent = true
        
        // pageNavigationView
        pageNavigationView.pageBackgroundColor = .clear
        pageNavigationView.registerPageCell(
            nib: UINib(nibName: MobileContentPageCell.nibName, bundle: nil),
            cellReuseIdentifier: MobileContentPageCell.reuseIdentifier
        )
        pageNavigationView.setContentInset(contentInset: .zero)
        pageNavigationView.setSemanticContentAttribute(semanticContentAttribute: viewModel.pageNavigationSemanticContentAttribute)
        
        if #available(iOS 11.0, *) {
            pageNavigationView.setContentInsetAdjustmentBehavior(contentInsetAdjustmentBehavior: .never)
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    func setupBinding() {
        
        viewModel.rendererWillChangeSignal.addObserver(self) { [weak self] in
            
            guard let pagesView = self else {
                return
            }
            
            pagesView.initialPagePositions.removeAll()
            pagesView.initialPagePositions = pagesView.getAllVisiblePagesPositions()
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
    
    private func getAllVisiblePagesPositions() -> [PageNumber: MobileContentPagePositionsType] {
                        
        var pagePositions: [PageNumber: MobileContentPagePositionsType] = Dictionary()
        
        let visiblePageCells: [UICollectionViewCell] = pageNavigationView.getVisiblePageCells()
        
        for cell in visiblePageCells {
            
            if let pageCell = cell as? MobileContentPageCell,
               let pageView = pageCell.mobileContentView as? MobileContentPageView,
               let indexPath = pageNavigationView.getIndexPathForPageCell(pageCell: pageCell) {
                
                let page: Int = indexPath.row
                let currentPagePositions: MobileContentPagePositionsType = pageView.getPagePositions()
                
                pagePositions[page] = currentPagePositions
            }
        }
        
        return pagePositions
    }
    
    func getPagePositions(page: Int) -> MobileContentPagePositionsType? {
        
        guard let pageCell = pageNavigationView.getCellForItem(indexPath: IndexPath(item: page, section: 0)) as? MobileContentPageCell else {
            return nil
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return nil
        }
        
        return pageView.getPagePositions()
    }
    
    func getCurrentPagePositions() -> MobileContentPagePositionsType? {
                
        guard let pageCell = pageNavigationView.currentPageCell as? MobileContentPageCell else {
            return nil
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return nil
        }
        
        return pageView.getPagePositions()
    }
    
    func setCurrentPagePositions(pagePositions: MobileContentPagePositionsType, animated: Bool) {
        
        guard let pageCell = pageNavigationView.currentPageCell as? MobileContentPageCell else {
            return
        }
        
        guard let pageView = pageCell.mobileContentView as? MobileContentPageView else {
            return
        }
        
        pageView.setPagePositions(pagePositions: pagePositions, animated: animated)
    }
    
    private func startNavigation(navigationModel: MobileContentPagesNavigationModel) {
        
        self.currentNavigation = navigationModel
        
        if !navigationModel.willReloadData {
            
            navigate(navigationModel: navigationModel)
        }
    }
    
    private func navigate(navigationModel: MobileContentPagesNavigationModel) {
                
        if pageNavigationView.currentPage == navigationModel.page {
            
            if let pagePositions = navigationModel.pagePositions {
                
                setCurrentPagePositions(pagePositions: pagePositions, animated: navigationModel.animated)
            }
            
            currentNavigation = nil
        }
        else {
            pageNavigationView.scrollToPage(page: navigationModel.page, animated: navigationModel.animated)
        }
    }
    
    private func completeCurrentNavigationIfNeeded() {
        
        if let navigationModel = currentNavigation {
            
            navigate(navigationModel: navigationModel)
        }
    }
}

// MARK: - PageNavigationCollectionViewDelegate

extension MobileContentPagesView: PageNavigationCollectionViewDelegate {
    
    func pageNavigationNumberOfPages(pageNavigation: PageNavigationCollectionView) -> Int {
        
        return viewModel.numberOfPages.value
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
        
        if let pagePositions = initialPagePositions[pageNumber] {
            pageView.setPagePositions(pagePositions: pagePositions, animated: false)
        }
        
        didConfigurePageView(pageView: pageView)
        
        initialPagePositions[pageNumber] = nil
        
        completeCurrentNavigationIfNeeded()
        
        return cell
    }
    
    func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
        view.endEditing(true)
    }
    
    func pageNavigationPageWillAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
    }
    
    func pageNavigationPageDidAppear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        if let contentPageCell = pageCell as? MobileContentPageCell {
            contentPageCell.mobileContentView?.viewDidAppear()
        }
        
        completeCurrentNavigationIfNeeded()
    }
    
    func pageNavigationPageWillDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        
    }
    
    func pageNavigationPageDidDisappear(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
                
        if let contentPageCell = pageCell as? MobileContentPageCell {
            contentPageCell.mobileContentView?.viewDidDisappear()
        }
        
        viewModel.pageDidDisappear(page: page)
    }
    
    func pageNavigationDidScrollPage(pageNavigation: PageNavigationCollectionView, page: Int) {
        
    }
}

// MARK: - MobileContentPageViewDelegate

extension MobileContentPagesView: MobileContentPageViewDelegate {
    
    func pageViewDidReceiveEvents(pageView: MobileContentPageView, events: [String]) {
        viewModel.pageDidReceiveEvents(events: events)
    }
    
    func pageViewDidReceiveUrl(pageView: MobileContentPageView, url: String) {
        viewModel.buttonWithUrlTapped(url: url)
    }
    
    func pageViewDidReceiveTrainingTipTap(pageView: MobileContentPageView, event: TrainingTipEvent) {
        viewModel.trainingTipTapped(event: event)
    }
    
    func pageViewDidReceiveError(pageView: MobileContentPageView, error: MobileContentErrorViewModel) {
        viewModel.errorOccurred(error: error)
    }
}
