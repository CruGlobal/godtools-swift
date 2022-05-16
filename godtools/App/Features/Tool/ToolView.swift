//
//  ToolView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolView: MobileContentPagesView {
    
    private let viewModel: ToolViewModelType
    private let navBarView: ToolNavBarView = ToolNavBarView()
                    
    required init(viewModel: ToolViewModelType) {
        self.viewModel = viewModel
        super.init(viewModel: viewModel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(viewModel: MobileContentPagesViewModelType) {
        fatalError("init(viewModel:) has not been implemented")
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
        
        navBarView.configure(
            parentViewController: self,
            viewModel: viewModel.navBarViewModel,
            delegate: self
        )
        
        viewModel.didSubscribeForRemoteSharePublishing.addObserver(self) { [weak self] (didSubscribeForRemoteSharePublishing: Bool) in
            guard let toolView = self else {
                return
            }
            if didSubscribeForRemoteSharePublishing {
                let page: Int = toolView.pageNavigationView.currentPage
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
        
        navBarView.reloadAppearance()
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
}

// MARK: - ToolNavBarViewDelegate

extension ToolView: ToolNavBarViewDelegate {
    
    func navBarHomeTapped(navBar: ToolNavBarView, remoteShareIsActive: Bool) {
        viewModel.navHomeTapped(remoteShareIsActive: remoteShareIsActive)
    }
    
    func navBarToolSettingsTapped(navBar: ToolNavBarView, selectedLanguage: LanguageModel) {
        
        let page: Int = pageNavigationView.currentPage
        
        viewModel.navToolSettingsTapped(page: page, selectedLanguage: selectedLanguage)
    }
    
    func navBarLanguageChanged(navBar: ToolNavBarView) {

        let page: Int = pageNavigationView.currentPage
        let pagePositions: MobileContentViewPositionState? = getCurrentPagePositions()
        
        guard let toolPagePositions = pagePositions as? ToolPagePositions else {
            return
        }
        
        viewModel.navLanguageChanged(page: page, pagePositions: toolPagePositions)
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
        pageNavigationView.scrollToNextPage(animated: true)
    }
}
