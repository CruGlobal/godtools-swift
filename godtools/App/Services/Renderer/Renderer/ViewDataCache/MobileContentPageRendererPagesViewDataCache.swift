//
//  MobileContentPageRendererPagesViewDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPageRendererPagesViewDataCache {
    
    typealias PageId = String
    
    private var pagesViewDataCache: [PageId: MobileContentPageViewDataCache] = Dictionary()
    
    init() {
        
    }
    
    func getPagesViewDataCache() -> [PageId: MobileContentPageViewDataCache] {
        return pagesViewDataCache
    }
    
    func getPagesViewDataCachePageIds() -> [PageId] {
        return Array(pagesViewDataCache.keys)
    }
    
    func getPageViewDataCache(page: Page) -> MobileContentPageViewDataCache {
        
        guard let dataCache = pagesViewDataCache[page.id] else {
            
            let newDataCache = MobileContentPageViewDataCache(page: page)
            pagesViewDataCache[page.id] = newDataCache
            
            return newDataCache
        }
        
        return dataCache
    }
    
    func storePageViewDataCache(page: Page, pageViewDataCache: MobileContentPageViewDataCache) {
        
        pagesViewDataCache[page.id] = pageViewDataCache
    }
    
    func deletePageViewDataCache(page: Page) {
        
        pagesViewDataCache[page.id] = MobileContentPageViewDataCache(page: page)
    }
    
    func clearCache() {
        
        pagesViewDataCache = Dictionary()
    }
}
