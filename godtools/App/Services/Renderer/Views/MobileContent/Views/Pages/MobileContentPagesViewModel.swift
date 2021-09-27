//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentPagesViewModel: NSObject, MobileContentPagesViewModelType {
    
    private let startingPage: Int?
    
    private var currentRenderer: MobileContentRendererType?
    private var safeArea: UIEdgeInsets?
    private var pageModels: [PageModelType] = Array()
    
    private weak var window: UIViewController?
    private weak var flowDelegate: FlowDelegate?
    
    let renderers: [MobileContentRendererType]
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: UISemanticContentAttribute
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    let pagesRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?) {
        
        self.flowDelegate = flowDelegate
        self.renderers = renderers
        self.startingPage = page
        
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            pageNavigationSemanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            pageNavigationSemanticContentAttribute = .forceRightToLeft
        }
        
        super.init()
    }
    
    deinit {

    }
    
    private func getIndexForFirstPageModel(pageModel: PageModelType) -> Int? {
        for index in 0 ..< pageModels.count {
            let activePageModel: PageModelType = pageModels[index]
            if activePageModel.uuid == pageModel.uuid {
                return index
            }
        }
        return nil
    }
    
    var primaryRenderer: MobileContentRendererType {
        
        guard let primaryRenderer = renderers.first else {
            assertionFailure("ViewModel does not contain any renderers.  Should have at least 1 renderer.")
            return renderers.first!
        }
        
        return primaryRenderer
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        guard let renderer = renderers.first else {
            return
        }
        
        if let startingPage = startingPage {
            
            let navigationModel = MobileContentPagesNavigationModel(
                willReloadData: true,
                page: startingPage,
                pagePositions: nil,
                animated: false
            )
            
            pageNavigation.accept(value: navigationModel)
        }
        
        setRenderer(renderer: renderer)
    }
    
    func setRenderer(renderer: MobileContentRendererType) {
        
        rendererWillChangeSignal.accept()
        
        currentRenderer = renderer
        
        let visiblePageModels: [PageModelType] = renderer.parser.getVisiblePageModels()
        
        pageModels = visiblePageModels
        
        numberOfPages.accept(value: pageModels.count)
    }
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard let renderer = self.currentRenderer else {
            return nil
        }
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        
        let renderPageResult: Result<MobileContentView, Error> =  renderer.renderPageModel(
            pageModel: pageModels[page],
            page: page,
            numberOfPages: pageModels.count,
            window: window,
            safeArea: safeArea,
            primaryRendererLanguage: primaryRenderer.language
        )
        
        switch renderPageResult {
        
        case .success(let mobileContentView):
            return mobileContentView
            
        case .failure(let error):
            break
        }
        
        return nil
    }
    
    func pageDidDisappear(page: Int) {
              
        let lastViewedPageModel: PageModelType = pageModels[page]
        
        guard lastViewedPageModel.isHidden else {
            return
        }
        
        // remove page
        pageModels.remove(at: page)
        numberOfPages.setValue(value: pageModels.count)
        pagesRemoved.accept(value: [IndexPath(item: page, section: 0)])
    }
    
    func pageDidReceiveEvents(eventIds: [MultiplatformEventId]) {
        
        guard let didReceivePageListenerForPageNumber = currentRenderer?.parser.getPageForListenerEvents(eventIds: eventIds) else {
            return
        }
        
        guard let didReceivePageListenerEventForPageModel = currentRenderer?.parser.getPageModel(page: didReceivePageListenerForPageNumber) else {
            return
        }
        
        let pageNumber: Int
        let willReloadData: Bool
        
        if let pageNumberExistsInActivatePages = getIndexForFirstPageModel(pageModel: didReceivePageListenerEventForPageModel) {
            
            pageNumber = pageNumberExistsInActivatePages
            willReloadData = false
        }
        else if didReceivePageListenerEventForPageModel.isHidden {
            
            if didReceivePageListenerForPageNumber < pageModels.count {
                pageModels.insert(didReceivePageListenerEventForPageModel, at: didReceivePageListenerForPageNumber)
                pageNumber = didReceivePageListenerForPageNumber
            }
            else {
                pageModels.append(didReceivePageListenerEventForPageModel)
                pageNumber = pageModels.count - 1
            }
            
            willReloadData = true
        }
        else {
            
            pageNumber = didReceivePageListenerForPageNumber
            willReloadData = false
        }
        
        let pageNavigationForReceivedPageListener = MobileContentPagesNavigationModel(
            willReloadData: willReloadData,
            page: pageNumber,
            pagePositions: nil,
            animated: true
        )
        
        pageNavigation.accept(value: pageNavigationForReceivedPageListener)
        
        if willReloadData {
            numberOfPages.accept(value: pageModels.count)
        }
    }
}
