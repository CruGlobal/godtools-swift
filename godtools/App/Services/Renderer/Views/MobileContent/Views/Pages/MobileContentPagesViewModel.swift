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
    private(set) var currentRenderedPageNumber: Int = 0
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
        return getPage(index: currentRenderedPageNumber)
    }
    
    func getPage(index: Int) -> Page? {
        
        guard index >= 0 && index < pageModels.count else {
            return nil
        }
        
        return pageModels[index]
    }
    
    func getNumberOfRenderedPages() -> Int {
        return pageModels.count
    }
    
    // MARK: - Navigation
    
    func pageDidReceiveEvent(eventId: EventId) -> ProcessedEventResult? {
                 
        return nil
    }
    
    func navigateToFirstPage(animated: Bool) {
        
        guard let page = getPage(index: 0) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToPreviousPage(animated: Bool) {
        
        guard let page = getPage(index: currentRenderedPageNumber - 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
    
    func navigateToNextPage(animated: Bool) {
        
        guard let page = getPage(index: currentRenderedPageNumber + 1) else {
            return
        }
        
        navigateToPage(page: page, animated: animated)
    }
        
    func navigateToPage(page: Page, animated: Bool) {
        
        let navigationEvent: MobileContentPagesNavigationEvent = getPageNavigationEvent(page: page, animated: animated)
        
        sendPageNavigationEvent(navigationEvent: navigationEvent)
    }
    
    func sendPageNavigationEvent(navigationEvent: MobileContentPagesNavigationEvent) {
            
        if let pages = navigationEvent.setPages, pages.count > 0 {
            setPages(pages: pages)
        }
        
        pageNavigationEventSignal.accept(value: navigationEvent)
    }
        
    func getPageNavigationEvent(page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool = false) -> MobileContentPagesNavigationEvent {
                
        let currentRenderedPages: [Page] = pageModels
                
        let pageIndexToNavigateTo: Int
        let insertPages: [Int]?
        let setPages: [Page]?
        
        if let indexForExistingPageInStack = currentRenderedPages.firstIndex(where: {$0.id == page.id}) {
            
            pageIndexToNavigateTo = indexForExistingPageInStack
            insertPages = nil
            setPages = currentRenderedPages
        }
        else {
            
            let pagePosition: Int32 = page.position
            let lastPageIndex: Int = pageModels.count - 1
            
            var insertAtIndex: Int = lastPageIndex
            
            for index in 0 ..< currentRenderedPages.count {
                
                let currentPagePosition: Int32 = currentRenderedPages[index].position
                
                if currentPagePosition > pagePosition {
                    insertAtIndex = index
                    break
                }
                else if index == lastPageIndex {
                    insertAtIndex = lastPageIndex + 1
                }
            }
            
            var pagesWithNewPage: [Page] = currentRenderedPages
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
            pagePositions: nil
        )
    }
    
    // MARK: - Page Life Cycle
    
    func pageWillAppear(page: Int) -> MobileContentView? {
        
        return nil
    }
    
    func pageDidAppear(page: Int) {
        
        currentRenderedPageNumber = page
        
        if page > highestPageNumberViewed {
            highestPageNumberViewed = page
        }
    }
    
    func pageDidDisappear(page: Int) {
                      
    }
    
    func didChangeMostVisiblePage(page: Int) {
        
        currentRenderedPageNumber = page
    }
    
    func didScrollToPage(page: Int) {

    }
}
