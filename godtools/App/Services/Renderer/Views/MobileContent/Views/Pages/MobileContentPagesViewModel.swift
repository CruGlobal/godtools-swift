//
//  MobileContentPagesViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

@MainActor class MobileContentPagesViewModel: NSObject, ObservableObject {
        
    private(set) var safeArea: UIEdgeInsets?
    private(set) var pageModels: [Page] = Array()
    private(set) var currentPageNumber: Int = 0
    private(set) var highestPageNumberViewed: Int = 0
    
    private(set) weak var window: UIViewController?
        
    let pageNavigationEventSignal: SignalValue<MobileContentPagesNavigationEvent> = SignalValue()
    
    override init() {
            
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
    
    func getPage(pageId: String) -> Page? {
        return pageModels.first(where: { $0.id == pageId })
    }
    
    func getNumberOfPages() -> Int {
        return pageModels.count
    }
    
    func getNearestAncestorPage(page: Page) -> Page? {
        
        guard let index = getNearestAncestorPageIndex(page: page) else {
            return nil
        }
        
        return getPage(index: index)
    }
    
    func getNearestAncestorPageIndex(page: Page) -> Int? {
        
        let pages: [Page] = getPages()
        
        var ancestor: Page? = page.parentPage
        
        while ancestor != nil {
            
            if let ancestorPageId = ancestor?.id,
               let ancestorPageIndex = pages.firstIndex(where: { $0.id == ancestorPageId }) {
                
                return ancestorPageIndex
            }
            
            ancestor = ancestor?.parentPage
        }
        
        return nil
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
    
    func navigateToPage(pageIndex: Int, animated: Bool) {
        
        guard let page = getPage(index: pageIndex) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
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
    
    func navigateToPage(pageId: String, animated: Bool) {
        
        guard let page = getPage(pageId: pageId) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToParentPage() {
        
        guard currentPageNumber > 0 else {
            return
        }
        
        let currentPage: Page? = getCurrentPage()
        let parentPage: Page? = currentPage?.parentPage ?? getPage(index: currentPageNumber - 1)
        let parentPageParams: [String: String]? = currentPage?.parentPageParams
        
        guard let parentPage = parentPage else {
            return
        }
        
        navigateToPage(
            page: parentPage,
            animated: true,
            parentPageParams: parentPageParams,
            isBackNavigation: true
        )
    }
        
    func navigateToPage(page: Page, animated: Bool, parentPageParams: [String: String]? = nil, isBackNavigation: Bool = false) {
        
        let navigationEvent: MobileContentPagesNavigationEvent = getPageNavigationEvent(
            page: page,
            animated: animated,
            parentPageParams: MobileContentParentPageParams(params: parentPageParams),
            isBackNavigation: isBackNavigation
        )
        
        sendPageNavigationEvent(navigationEvent: navigationEvent)
    }
    
    func getPageNavigationEvent(page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool = false, parentPageParams: MobileContentParentPageParams? = nil, isBackNavigation: Bool = false) -> MobileContentPagesNavigationEvent {
                
        let currentPages: [Page] = pageModels
                
        let pageIndexToNavigateTo: Int
        let insertPages: [Int]?
        let setPages: [Page]?
        
        if let indexForExistingPageInStack = currentPages.firstIndex(where: {$0.id == page.id}) {
            
            pageIndexToNavigateTo = indexForExistingPageInStack
            insertPages = nil
            setPages = currentPages
        }
        else {
            
            let pagePosition: Int32 = page.position
            let lastPageIndex: Int = pageModels.count - 1
            
            var insertAtIndex: Int = lastPageIndex
            
            for index in 0 ..< currentPages.count {
                
                let currentPagePosition: Int32 = currentPages[index].position
                
                if currentPagePosition > pagePosition {
                    insertAtIndex = index
                    break
                }
                else if index == lastPageIndex {
                    insertAtIndex = lastPageIndex + 1
                }
            }
            
            var pagesWithNewPage: [Page] = currentPages
            pagesWithNewPage.insert(page, at: insertAtIndex)

            pageIndexToNavigateTo = insertAtIndex
            insertPages = [insertAtIndex]
            setPages = pagesWithNewPage
        }
                
        return MobileContentPagesNavigationEvent(
            pageNavigation: PageNavigationCollectionViewNavigationModel(
                navigationDirection: nil,
                page: pageIndexToNavigateTo,
                animated: animated,
                reloadCollectionViewDataNeeded: reloadCollectionViewDataNeeded,
                insertPages: insertPages,
                deletePages: nil
            ),
            setPages: setPages,
            pagePositions: nil,
            parentPageParams: parentPageParams,
            pageSubIndex: nil
        )
    }
    
    // MARK: - Page Life Cycle
    
    func pageWillAppear(page: Int, pageParams: MobileContentPageWillAppearParams) -> MobileContentView? {
        
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
