//
//  ToolView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolView: MobileContentPagesView {
    
    private let viewModel: ToolViewModel
                    
    init(viewModel: ToolViewModel, navigationBar: AppNavigationBar?) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel, navigationBar: navigationBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
    }
    
    override func setupLayout() {
        super.setupLayout()
    }
    
    override func setupBinding() {
        super.setupBinding()
        
        viewModel.didSubscribeForRemoteSharePublishing.addObserver(self) { [weak self] (didSubscribeForRemoteSharePublishing: Bool) in
            guard let toolView = self else {
                return
            }
            if didSubscribeForRemoteSharePublishing {
                let page: Int = toolView.pageNavigationView.getCurrentPage()
                let pagePositions: MobileContentViewPositionState? = toolView.getPagePositions(page: page)
                guard let toolPagePositions = pagePositions as? ToolPagePositions else {
                    return
                }
                toolView.viewModel.subscribedForRemoteSharePublishing(page: page, pagePositions: toolPagePositions)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didConfigurePageView(pageView: MobileContentPageView) {
        if let toolPageView = pageView as? ToolPageView {
            toolPageView.setToolPageDelegate(delegate: self)
        }
    }
    
    override func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        super.pageNavigationDidChangeMostVisiblePage(pageNavigation: pageNavigation, pageCell: pageCell, page: page)
                
        let pagePositions: MobileContentViewPositionState? = getPagePositions(page: page)
        
        guard let toolPagePositions = pagePositions as? ToolPagePositions else {
            return
        }
        
        viewModel.pageChanged(page: page, pagePositions: toolPagePositions)
    }
    
    func languageTapped(index: Int) {
        
        let page: Int = pageNavigationView.getCurrentPage()
        let pagePositions: MobileContentViewPositionState? = getCurrentPagePositions()
        
        guard let toolPagePositions = pagePositions as? ToolPagePositions else {
            return
        }
        
        viewModel.languageTapped(index: index, page: page, pagePositions: toolPagePositions)
    }
}

// MARK: - ToolPageViewDelegate

extension ToolView: ToolPageViewDelegate {
    
    func toolPageCardPositionChanged(pageView: ToolPageView, page: Int, cardPosition: Int?, animated: Bool) {

        let pagePositionsForCardChange = ToolPagePositions(
            cardPosition: cardPosition
        )
        
        viewModel.pageChanged(page: page, pagePositions: pagePositionsForCardChange)
    }
    
    func toolPageCallToActionNextButtonTapped(pageView: ToolPageView, page: Int) {
        viewModel.navigateToNextPage(animated: true)
    }
}
