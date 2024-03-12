//
//  MobileContentPageViewDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 4/4/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentPageViewDataCache {
    
    private var dataCache: [String: Any] = Dictionary()
    
    let pageId: String
    let pagePosition: Int32
    
    init(page: Page) {
        
        pageId = page.id
        pagePosition = page.position
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    var isEmpty: Bool {
        return dataCache.isEmpty
    }
    
    func getValue(key: String) -> Any? {
        return dataCache[key]
    }
    
    func storeValue(key: String, value: Any) {
        dataCache[key] = value
    }
}
