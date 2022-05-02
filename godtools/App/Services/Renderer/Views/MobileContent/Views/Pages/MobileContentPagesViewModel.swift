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
    
    private var safeArea: UIEdgeInsets?
    private var pageModels: [Page] = Array()
    
    private(set) var currentPageRenderer: MobileContentPageRenderer?
    private(set) var currentPage: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    
    private(set) weak var window: UIViewController?
    private(set) weak var flowDelegate: FlowDelegate?
    
    let renderer: MobileContentRenderer
    let numberOfPages: ObservableValue<Int> = ObservableValue(value: 0)
    let pageNavigationSemanticContentAttribute: UISemanticContentAttribute
    let rendererWillChangeSignal: Signal = Signal()
    let pageNavigation: ObservableValue<MobileContentPagesNavigationModel?> = ObservableValue(value: nil)
    let pagesRemoved: ObservableValue<[IndexPath]> = ObservableValue(value: [])
    
    required init(flowDelegate: FlowDelegate, renderer: MobileContentRenderer, page: Int?, mobileContentEventAnalytics: MobileContentEventAnalyticsTracking, initialPageRenderingType: MobileContentPagesInitialPageRenderingType) {
        
        self.flowDelegate = flowDelegate
        self.renderer = renderer
        self.startingPage = page
        self.mobileContentEventAnalytics = mobileContentEventAnalytics
        self.initialPageRenderingType = initialPageRenderingType
        
        switch renderer.primaryLanguage.languageDirection {
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
    
    private func getRendererPageModelsMatchingCurrentRenderedPageModels(pageRenderer: MobileContentPageRenderer) -> [Page] {
        
        var rendererPageModelsMatchingCurrentRenderedPageModels: [Page] = Array()
        
        let currentRenderedPageModels: [Page] = pageModels
        let allPageModelsInNewRenderer: [Page] = pageRenderer.getRenderablePageModels()
        
        for pageModel in currentRenderedPageModels {
                        
            guard let setRendererPageModel = allPageModelsInNewRenderer.filter({$0.id == pageModel.id}).first else {
                continue
            }
            
            rendererPageModelsMatchingCurrentRenderedPageModels.append(setRendererPageModel)
        }
        
        return rendererPageModelsMatchingCurrentRenderedPageModels
    }
    
    private func getIndexForFirstPageModel(pageModel: Page) -> Int? {
        for index in 0 ..< pageModels.count {
            let activePageModel: Page = pageModels[index]
            if activePageModel.id == pageModel.id {
                return index
            }
        }
        return nil
    }
    
    private func removePage(page: Int) {
        
        let pageIsInArrayBounds: Bool = page >= 0 && page < pageModels.count
        
        guard pageIsInArrayBounds else {
            return
        }
        
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
        
        let lastViewedPageModel: Page = pageModels[page]
        
        guard lastViewedPageModel.isHidden else {
            return
        }
        
        removePage(page: page)
    }
    
    private func trackContentEvents(eventIds: [EventId]) {
        
        guard let language = currentPageRenderer?.language else {
            assertionFailure("Failed to track content event for current page renderer.  Language was not found.")
            return
        }
        
        mobileContentEventAnalytics.trackContentEvents(eventIds: eventIds, resource: renderer.resource, language: language)
    }
    
    private func didReceivePageListenerForPage(page: Int, pageModel: Page) {
        
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
    
    var primaryPageRenderer: MobileContentPageRenderer {
        
        guard let primaryPageRenderer = renderer.pageRenderers.first else {
            assertionFailure("ViewModel does not contain any renderers.  It should have at least 1 renderer.")
            return renderer.pageRenderers[0]
        }
        
        return primaryPageRenderer
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
        
        guard let pageRenderer = renderer.pageRenderers.first else {
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
        
        setPageRenderer(pageRenderer: pageRenderer)
    }
    
    func setPageRenderer(pageRenderer: MobileContentPageRenderer) {
        
        let pageRenderers: [MobileContentPageRenderer] = renderer.pageRenderers
        let pageModelsToRender: [Page]
        
        switch initialPageRenderingType {
        
        case .chooseYourOwnAdventure:
            
            let pagesShouldMatchRenderedPages: Bool = pageRenderers.count > 1 && pageModels.count > 1
            
            var newPageModelsToRenderer: [Page] = Array()
            
            if pagesShouldMatchRenderedPages {
                
                newPageModelsToRenderer = getRendererPageModelsMatchingCurrentRenderedPageModels(pageRenderer: pageRenderer)
            }
            
            if newPageModelsToRenderer.isEmpty && pageRenderer.getRenderablePageModels().count > 0 {
                
                newPageModelsToRenderer = [pageRenderer.getRenderablePageModels()[0]]
            }

            pageModelsToRender = newPageModelsToRenderer
            
        case .visiblePages:
            
            pageModelsToRender = pageRenderer.getVisibleRenderablePageModels()
        }
        
        
        rendererWillChangeSignal.accept()
        
        currentPageRenderer = pageRenderer
        
        self.pageModels = pageModelsToRender
        
        numberOfPages.accept(value: pageModels.count)
    }
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard let currentPageRenderer = self.currentPageRenderer else {
            return nil
        }
        
        guard page >= 0 && page < pageModels.count else {
            return nil
        }
        
        let renderPageResult: Result<MobileContentView, Error> =  currentPageRenderer.renderPageModel(
            pageModel: pageModels[page],
            page: page,
            numberOfPages: pageModels.count,
            window: window,
            safeArea: safeArea
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

        guard let currentPageRenderer = currentPageRenderer else {
            return
        }
        
        for eventId in eventIds {
            if currentPageRenderer.manifest.dismissListeners.contains(eventId) {
                dismissPages()
                return
            }
        }
                        
        if let didReceivePageListenerForPageNumber = currentPageRenderer.getPageForListenerEvents(eventIds: eventIds),
           let didReceivePageListenerEventForPageModel = currentPageRenderer.getPageModel(page: didReceivePageListenerForPageNumber)  {
            
            didReceivePageListenerForPage(
                page: didReceivePageListenerForPageNumber,
                pageModel: didReceivePageListenerEventForPageModel
            )
        }
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentPage = page
    }
    
    func dismissPages() {
        
        flowDelegate?.navigate(step: .dismissRendererPages)
    }
}
