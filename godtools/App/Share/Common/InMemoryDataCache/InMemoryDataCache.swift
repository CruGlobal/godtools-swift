//
//  InMemoryDataCache.swift
//  godtools
//
//  Created by Levi Eggert on 5/14/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class InMemoryDataCache {
    
    private static let oneHundredMegabytes: Int = 1024 * 1024 * 100
    
    private let cache = NSCache<NSString, NSData>()
    
    init(countLimit: Int = 100, totalCostLimit: Int = InMemoryDataCache.oneHundredMegabytes) {
        
        cache.countLimit = countLimit
        cache.totalCostLimit = totalCostLimit
    }
    
    func cacheData(id: String, data: Data) {
        
        cache.setObject(data as NSData, forKey: id as NSString)
    }
    
    func getData(id: String) -> Data? {
        
        guard let nsData = cache.object(forKey: NSString(string: id)) else {
            return nil
        }
        
        return nsData as Data
    }
}
