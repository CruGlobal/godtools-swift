//
//  MobileContentPagesNavigation.swift
//  godtools
//
//  Created by Levi Eggert on 2/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPagesNavigation {
    
    init() {
        
    }
    
    func getPageNavigationEvent(pages: [Page], page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool) -> MobileContentPagesNavigationEvent {
                
        let currentPages: [Page] = pages
                
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
            let lastPageIndex: Int = pages.count - 1
            
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
            pagePositions: nil
        )
    }
}
