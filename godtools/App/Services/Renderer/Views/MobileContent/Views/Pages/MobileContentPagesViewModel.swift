//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

class MobileContentPagesViewModel: NSObject, ObservableObject {
    
    private(set) var safeArea: UIEdgeInsets?
    private(set) var pageModels: [Page] = Array()
    private(set) var currentPageNumber: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    
    private(set) weak var window: UIViewController?
        
    let pagesNavigation: MobileContentPagesNavigation
    let pageNavigationEventSignal: SignalValue<MobileContentPagesNavigationEvent> = SignalValue()
    
    init(pagesNavigation: MobileContentPagesNavigation) {
            
        self.pagesNavigation = pagesNavigation
        
        super.init()
    }
    
    var layoutDirection: UISemanticContentAttribute {
        return .forceLeftToRight
    }
    
    func viewDidFinishLayout(window: UIViewController, safeArea: UIEdgeInsets) {
        
        self.window = window
        self.safeArea = safeArea
    }
    
    // MARK: - Pages
        
    func getPages() -> [Page] {
        return pageModels
    }
    
    func setPages(pages: [Page]) {
        pageModels = pages
    }

    func getCurrentPage() -> Page? {
        return getPage(index: currentPageNumber)
    }
    
    func getPage(index: Int) -> Page? {
        
        guard index >= 0 && index < pageModels.count else {
            return nil
        }
        
        return pageModels[index]
    }
    
    func getNumberOfPages() -> Int {
        return pageModels.count
    }
    
    // MARK: - Events
    
    func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {
        
        return nil
    }
    
    // MARK: - Event Navigation
    
    func checkEventForPageListenerAndNavigate(listeningPages: [Page], eventId: EventId) -> Bool {
        
        let pageToNavigateTo: Page?
        
        if let listenerPage = getPageToNavigateToForPageListener(listeningPages: listeningPages, eventId: eventId) {
            
            pageToNavigateTo = listenerPage
        }
        else if let dismissListenerPage = getPageToNavigateToForPageDismissListener(listeningPages: listeningPages, eventId: eventId) {
            
            pageToNavigateTo = dismissListenerPage
        }
        else {
            
            pageToNavigateTo = nil
        }
        
        if let pageToNavigateTo = pageToNavigateTo {
            
            navigateToPage(page: pageToNavigateTo, animated: true)
            
            return true
        }
        else {
            
            return false
        }
    }
    
    func getPageToNavigateToForPageListener(listeningPages: [Page], eventId: EventId) -> Page? {
                            
        if let pageListeningForEvent = listeningPages.first(where: {$0.listeners.contains(eventId)}) {
            return pageListeningForEvent
        }
        
        return nil
    }
    
    func getPageToNavigateToForPageDismissListener(listeningPages: [Page], eventId: EventId) -> Page? {
                    
        if let pageDismissEvent = listeningPages.first(where: {$0.dismissListeners.contains(eventId)}) {
            return pageDismissEvent.parentPage
        }
        
        return nil
    }
    
    func sendPageNavigationEvent(navigationEvent: MobileContentPagesNavigationEvent) {
            
        if let pages = navigationEvent.setPages, pages.count > 0 {
            setPages(pages: pages)
        }
        
        pageNavigationEventSignal.accept(value: navigationEvent)
    }
    
    // MARK: - Navigation
    
    func navigateToFirstPage(animated: Bool) {
        
        guard let page = getPage(index: 0) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToPreviousPage(animated: Bool) {
        
        guard let page = getPage(index: currentPageNumber - 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToNextPage(animated: Bool) {
        
        guard let page = getPage(index: currentPageNumber + 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
        
    func navigateToPage(page: Page, animated: Bool) {
        
        let currentPages: [Page] = pageModels
                
        let navigationEvent: MobileContentPagesNavigationEvent =  pagesNavigation.getPageNavigationEvent(
            pages: currentPages,
            page: page,
            animated: animated,
            reloadCollectionViewDataNeeded: false
        )
                
        sendPageNavigationEvent(navigationEvent: navigationEvent)
    }
        
    // MARK: - Page Life Cycle
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        return nil
    }
    
    func pageDidAppear(page: Int) {
        
        currentPageNumber = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
                      
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentPageNumber = page
    }
    
    func didScrollToPage(page: Int) {

    }
}
