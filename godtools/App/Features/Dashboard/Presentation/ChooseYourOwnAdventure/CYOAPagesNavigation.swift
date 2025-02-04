//
//  CYOAPagesNavigation.swift
//  godtools
//
//  Created by Levi Eggert on 2/4/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class CYOAPagesNavigation: MobileContentPagesNavigation {
    
    override init() {
        
        super.init()
    }
    
    override func getPageNavigationEvent(pages: [Page], page: Page, animated: Bool, reloadCollectionViewDataNeeded: Bool) -> MobileContentPagesNavigationEvent {
                
        if pages.count == 1 && page.id == pages[0].id {
            
            return MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: 0,
                    animated: false,
                    reloadCollectionViewDataNeeded: true,
                    insertPages: nil,
                    deletePages: nil
                ),
                setPages: nil,
                pagePositions: nil
            )
        }
        
        let navigationEvent: MobileContentPagesNavigationEvent
        
        if let backToPageIndex = pages.firstIndex(of: page) {
            
            // Backward Navigation
            
            let removeStartIndex: Int = backToPageIndex + 1
            let removedEndIndex: Int = pages.count - 1
            
            let pageIndexesToRemove: [Int]
            
            if removeStartIndex <= removedEndIndex {
                pageIndexesToRemove = Array(removeStartIndex...removedEndIndex)
            }
            else {
                pageIndexesToRemove = Array()
            }
            
            let pagesUpToBackToPage: [Page] = Array(pages[0...backToPageIndex])
            
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: backToPageIndex,
                    animated: true,
                    reloadCollectionViewDataNeeded: false,
                    insertPages: nil,
                    deletePages: pageIndexesToRemove
                ),
                setPages: pagesUpToBackToPage,
                pagePositions: nil
            )
        }
        else {
            
            // Forward Navigation
            
            let insertAtEndIndex: Int = pages.count
                        
            navigationEvent = MobileContentPagesNavigationEvent(
                pageNavigation: PageNavigationCollectionViewNavigationModel(
                    navigationDirection: nil,
                    page: insertAtEndIndex,
                    animated: true,
                    reloadCollectionViewDataNeeded: false,
                    insertPages: [insertAtEndIndex],
                    deletePages: nil
                ),
                setPages: pages + [page],
                pagePositions: nil
            )
        }
        
        return navigationEvent
    }
}
