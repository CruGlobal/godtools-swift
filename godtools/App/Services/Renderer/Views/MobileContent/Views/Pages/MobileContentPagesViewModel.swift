//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPagesViewModel: NSObject, MobileContentPagesViewModelType {
    
    private let mobileContentEventAnalytics: MobileContentEventAnalyticsTracking
    private let initialPageRenderingType: MobileContentPagesInitialPageRenderingType
    private let startingPage: Int?
    
    private var currentRenderer: MobileContentRendererType?
    private var safeArea: UIEdgeInsets?
    private var pageModels: [PageModelType] = Array()
    
    private(set) var currentPage: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    
    private(set) weak var window: UIViewController?
    private(set) weak var flowDelegate: FlowDelegate?
    
    let renderers: [MobileContentRendererType]
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: UISemanticContentAttribute
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    let pagesRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    
    required init(flowDelegate: FlowDelegate, renderers: [MobileContentRendererType], primaryLanguage: LanguageModel, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        
        self.flowDelegate = flowDelegate
        self.renderers = renderers
        self.startingPage = page
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            pageNavigationSemanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            pageNavigationSemanticContentAttribute = .forceRightToLeft
        }
        
        if let page = page {
            currentPage = page
        }
        
        super.init()
    }
    
    deinit {

    }
    
    func getCurrentRenderer() -> MobileContentRendererType? {
        return currentRenderer
    }
    
    private func getRendererPageModelsMatchingCurrentRenderedPageModels(renderer: MobileContentRendererType) -> [PageModelType] {
        
        var rendererPageModelsMatchingCurrentRenderedPageModels: [PageModelType] = Array()
        
        let currentRenderedPageModels: [PageModelType] = pageModels
        let allPageModelsInNewRenderer: [PageModelType] = renderer.parser.pageModels
        
        for pageModel in currentRenderedPageModels {
                        
            guard let setRendererPageModel = allPageModelsInNewRenderer.filter({$0.id == pageModel.id}).first else {
                continue
            }
            
            rendererPageModelsMatchingCurrentRenderedPageModels.append(setRendererPageModel)
        }
        
        return rendererPageModelsMatchingCurrentRenderedPageModels
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
    
    private func removePage(page: Int) {
        
        pageModels.remove(at: page)
        numberOfPages.setValue(value: pageModels.count)
        pagesRemoved.accept(value: [IndexPath(item: page, section: 0)])
    }
    
    private func removeFollowingPagesFromPage(page: Int) {
        
        let nextPage: Int = currentPage + 1
        
        for index in nextPage ..< pageModels.count {
            removePage(page: index)
        }
    }
    
    private func removePageIfHidden(page: Int) {
        
        let indexIsInRange: Bool = page >= 0 && page < pageModels.count
        
        guard indexIsInRange else {
            return
        }
        
        let lastViewedPageModel: PageModelType = pageModels[page]
        
        guard lastViewedPageModel.isHidden else {
            return
        }
        
        removePage(page: page)
    }
    
    private func trackContentEvents(eventIds: [EventId]) {
        
        guard let resource = currentRenderer?.resource else {
            assertionFailure("Failed to track content event for current renderer.  Resource was not found.")
            return
        }
        
        guard let language = currentRenderer?.language else {
            assertionFailure("Failed to track content event for current renderer.  Language was not found.")
            return
        }
        
        mobileContentEventAnalytics.trackContentEvents(eventIds: eventIds, resource: resource, language: language)
    }
    
    private func didReceivePageListenerForPage(page: Int, pageModel: PageModelType) {
        
        let isChooseYourOwnAdventure: Bool = initialPageRenderingType == .chooseYourOwnAdventure
        
        let pageNumber: Int
        let willReloadData: Bool
        
        if let pageNumberExistsInActivatePages = getIndexForFirstPageModel(pageModel: pageModel) {
            
            pageNumber = pageNumberExistsInActivatePages
            willReloadData = false
        }
        else if pageModel.isHidden || isChooseYourOwnAdventure {
            
            let insertAtPage: Int = currentPage + 1
            
            if insertAtPage < pageModels.count {
                
                pageModels.insert(pageModel, at: insertAtPage)
                pageNumber = insertAtPage
            }
            else {
                pageModels.append(pageModel)
                pageNumber = pageModels.count - 1
            }
            
            willReloadData = true
        }
        else {
            
            pageNumber = page
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
        
        let pageModelsToRender: [PageModelType]
        
        switch initialPageRenderingType {
        
        case .chooseYourOwnAdventure:
            
            let pagesShouldMatchRenderedPages: Bool = renderers.count > 1 && pageModels.count > 1
            
            var newPageModelsToRenderer: [PageModelType] = Array()
            
            if pagesShouldMatchRenderedPages {
                
                newPageModelsToRenderer = getRendererPageModelsMatchingCurrentRenderedPageModels(renderer: renderer)
            }
            
            if newPageModelsToRenderer.isEmpty && renderer.parser.pageModels.count > 0 {
                
                newPageModelsToRenderer = [renderer.parser.pageModels[0]]
            }

            pageModelsToRender = newPageModelsToRenderer
            
        case .visiblePages:
            
            pageModelsToRender = renderer.parser.getVisiblePageModels()
        }
        
        
        rendererWillChangeSignal.accept()
        
        currentRenderer = renderer
        
        self.pageModels = pageModelsToRender
        
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
    
    func pageDidAppear(page: Int) {
        
        currentPage = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
              
        let didNavigateBack: Bool = currentPage < page
        let shouldRemoveAllFollowingPages: Bool = initialPageRenderingType == .chooseYourOwnAdventure && didNavigateBack
        
        if shouldRemoveAllFollowingPages {
            removeFollowingPagesFromPage(page: currentPage)
        }
        
        removePageIfHidden(page: page)
    }
    
    func pageDidReceiveEvents(eventIds: [EventId]) {
    
        trackContentEvents(eventIds: eventIds)
        
        if let didReceivePageListenerForPageNumber = currentRenderer?.parser.getPageForListenerEvents(eventIds: eventIds),
           let didReceivePageListenerEventForPageModel = currentRenderer?.parser.getPageModel(page: didReceivePageListenerForPageNumber)  {
            
            didReceivePageListenerForPage(
                page: didReceivePageListenerForPageNumber,
                pageModel: didReceivePageListenerEventForPageModel
            )
        }
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentPage = page
    }
}
