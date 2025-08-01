//
//  TractView.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Combine

class TractView: MobileContentRendererView {
    
    private let viewModel: TractViewModel
    
    private var cancellables: Set<AnyCancellable> = Set()
                    
    init(viewModel: TractViewModel, navigationBar: AppNavigationBar?) {
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
        
        addScreenAccessibility(screenAccessibility: .tract)
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
                guard let tractPagePositions = pagePositions as? TractPagePositions else {
                    return
                }
                toolView.viewModel.subscribedForRemoteSharePublishing(page: page, pagePositions: tractPagePositions)
            }
        }
        
        viewModel.$toolSettingsDidClose
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (didClose: Void?) in
                
                guard let weakSelf = self, didClose != nil else {
                    return
                }
                
                guard let tractPagePositions = weakSelf.getCurrentPagePositions() as? TractPagePositions else {
                    return
                }
                
                weakSelf.viewModel.sendRemoteShareNavigationEvent(
                    page:  weakSelf.pageNavigationView.getCurrentPage(),
                    pagePositions: tractPagePositions
                )
            }
            .store(in: &cancellables)
    }
    
    override func didConfigurePageView(pageView: MobileContentPageView) {
        if let tractPageView = pageView as? TractPageView {
            tractPageView.setTractPageDelegate(delegate: self)
        }
    }
    
    override func pageNavigationDidChangeMostVisiblePage(pageNavigation: PageNavigationCollectionView, pageCell: UICollectionViewCell, page: Int) {
        super.pageNavigationDidChangeMostVisiblePage(pageNavigation: pageNavigation, pageCell: pageCell, page: page)
                
        let pagePositions: MobileContentViewPositionState? = getPagePositions(page: page)
        
        guard let tractPagePositions = pagePositions as? TractPagePositions else {
            return
        }
        
        viewModel.pageChanged(page: page, pagePositions: tractPagePositions)
    }
    
    func languageTapped(index: Int) {
        
        let page: Int = pageNavigationView.getCurrentPage()
        let pagePositions: MobileContentViewPositionState? = getCurrentPagePositions()
        
        guard let tractPagePositions = pagePositions as? TractPagePositions else {
            return
        }
        
        viewModel.languageTapped(index: index, page: page, pagePositions: tractPagePositions)
    }
}

// MARK: - TractPageViewDelegate

extension TractView: TractPageViewDelegate {
    
    func tractPageCardPositionChanged(pageView: TractPageView, page: Int, cardPosition: Int?, animated: Bool) {

        let pagePositionsForCardChange = TractPagePositions(
            cardPosition: cardPosition
        )
        
        viewModel.pageChanged(page: page, pagePositions: pagePositionsForCardChange)
    }
    
    func tractPageCallToActionNextButtonTapped(pageView: TractPageView, page: Int) {
        viewModel.navigateToNextPage(animated: true)
    }
}
