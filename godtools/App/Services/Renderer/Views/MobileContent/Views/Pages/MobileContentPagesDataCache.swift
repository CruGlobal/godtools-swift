//
//  MobileContentPagesDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MobileContentPagesDataCache {
    
    private var cachedPageData: [MobileContentPagesView.PageNumber: [String: Any]]
    
    init(cachedPageData: [MobileContentPagesView.PageNumber: [String: Any]] = Dictionary()) {
        
        self.cachedPageData = cachedPageData
    }
    
    func getCachedDataForPage(page: Int) -> [String: Any]? {
        return cachedPageData[page]
    }
    
    func storeCachedDataForPage(page: Int, data: [String: Any]) {
        cachedPageData[page] = data
    }
}
