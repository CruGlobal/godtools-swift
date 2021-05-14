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
    private var pages: [PageNode] = Array()
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
        removeObserversFromCurrentRenderer()
    }
    
    private func removeObserversFromCurrentRenderer() {
        currentRenderer?.pages.removeObserver(self)
    }
    
    private func removePage(pageNode: PageNode) {
        if let pageIndex = pages.firstIndex(of: pageNode) {
            pages.remove(at: pageIndex)
            numberOfPages.setValue(value: pages.count)
            pagesRemoved.accept(value: [IndexPath(item: pageIndex, section: 0)])
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
        
        removeObserversFromCurrentRenderer()
        
        rendererWillChangeSignal.accept()
        
        currentRenderer = renderer
        
        renderer.pages.addObserver(self) { [weak self] (pages: [PageNode]) in
            
            let visiblePages: [PageNode] = pages.filter({!$0.isHidden})
            
            self?.pages = visiblePages
            self?.numberOfPages.accept(value: visiblePages.count)
        }
    }
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        guard let window = self.window, let safeArea = self.safeArea else {
            return nil
        }
        
        guard let renderer = self.currentRenderer else {
            return nil
        }
        
        let renderPageResult: Result<MobileContentView, Error> = renderer.renderPageFromPageNodes(
            pageNodes: pages,
            page: page,
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
                
        guard let pageNode = currentRenderer?.getPageNode(page: page) else {
            return
        }
        
        if pages.contains(pageNode) && pageNode.isHidden {
            removePage(pageNode: pageNode)
        }
    }
    
    func pageDidReceiveEvents(events: [String]) {
        
        guard let didReceivePageListenerForPageNumber = currentRenderer?.getPageForListenerEvents(events: events) else {
            return
        }
        
        guard let didReceivePageListenerEventForPageNode = currentRenderer?.getPageNode(page: didReceivePageListenerForPageNumber) else {
            return
        }
        
        let pageNumber: Int
        let willReloadData: Bool
        
        if let pageNumberExistsInActivatePages = pages.firstIndex(of: didReceivePageListenerEventForPageNode) {
            
            pageNumber = pageNumberExistsInActivatePages
            willReloadData = false
        }
        else if didReceivePageListenerEventForPageNode.isHidden {
            
            if didReceivePageListenerForPageNumber < pages.count {
                pages.insert(didReceivePageListenerEventForPageNode, at: didReceivePageListenerForPageNumber)
                pageNumber = didReceivePageListenerForPageNumber
            }
            else {
                pages.append(didReceivePageListenerEventForPageNode)
                pageNumber = pages.count - 1
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
            numberOfPages.accept(value: pages.count)
        }
    }
    
    func buttonWithUrlTapped(url: String) {
        flowDelegate?.navigate(step: .buttonWithUrlTappedFromMobileContentRenderer(url: url))
    }
    
    func trainingTipTapped(event: TrainingTipEvent) {
        flowDelegate?.navigate(step: .trainingTipTappedFromMobileContentRenderer(event: event))
    }
    
    func errorOccurred(error: MobileContentErrorViewModel) {
        flowDelegate?.navigate(step: .errorOccurredFromMobileContentRenderer(error: error))
    }
}
