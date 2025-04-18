//
//  MobileContentPageCollectionView.swift
//  godtools
//
//  Created by Levi Eggert on 1/31/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPageCollectionView: MobileContentPageView {
    
    private let viewModel: MobileContentPageCollectionViewModel
    private let pagesView: MobileContentPagesView
    
    init(viewModel: MobileContentPageCollectionViewModel) {
        
        self.viewModel = viewModel
        
        self.pagesView = MobileContentPagesView(
            viewModel: viewModel.pagesViewModel,
            navigationBar: nil,
            pageViewDelegate: nil,
            initialPageIndex: nil,
            loggingEnabled: false
        )
        
        super.init(viewModel: viewModel, nibName: nil)
        
        pagesView.setPageViewDelegate(pageViewDelegate: self)
    }
    
    @MainActor required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupLayout() {
        super.setupLayout()
                  
        // pagesView
        addSubview(pagesView.view)
        pagesView.view.translatesAutoresizingMaskIntoConstraints = false
        pagesView.view.constrainEdgesToView(view: self)
    }
    
    override func setupBinding() {
        super.setupBinding()
    }
    
    override func getPositionState() -> MobileContentViewPositionState {
        
        return MobileContentPageCollectionPositionState(
            currentPageNumber: viewModel.pagesViewModel.currentPageNumber
        )
    }
    
    override func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
        guard let positionState = positionState as? MobileContentPageCollectionPositionState else {
            return
        }
        
        pagesView.navigateToPage(pageIndex: positionState.currentPageNumber, animated: animated)
    }
    
    override func viewDidAppear(navigationEvent: MobileContentPagesNavigationEvent?) {
        super.viewDidAppear(navigationEvent: navigationEvent)
        
        if let activePageId = navigationEvent?.parentPageParams?.activePageId {
            
            // NOTE: Method viewDidAppear is triggered from UICollectionView willDisplayCell in PageNavigationCollectionView.swift.
            // For some reason attempting to scroll a collection view will not correctly scroll and using this Dispatch resolves that.
            // Would like to resolve this so DispatchQueue.main.async is not needed. ~Levi
           
            DispatchQueue.main.async { [weak self] in
                self?.pagesView.navigateToPage(pageId: activePageId, animated: false)
            }
        }
        else if let pageSubIndex = navigationEvent?.pageSubIndex {
            
            // NOTE: Method viewDidAppear is triggered from UICollectionView willDisplayCell in PageNavigationCollectionView.swift.
            // For some reason attempting to scroll a collection view will not correctly scroll and using this Dispatch resolves that.
            // Would like to resolve this so DispatchQueue.main.async is not needed. ~Levi
           
            DispatchQueue.main.async { [weak self] in
                self?.pagesView.navigateToPage(pageIndex: pageSubIndex, animated: false)
            }
        }
    }
}

// MARK: - MobileContentPageViewDelegate

extension MobileContentPageCollectionView: MobileContentPageViewDelegate {
    
    func pageViewDidReceiveEvent(pageView: MobileContentPageView, eventId: EventId) -> ProcessedEventResult? {
        
        return getPageViewDelegate()?.pageViewDidReceiveEvent(pageView: pageView, eventId: eventId)
    }
}
