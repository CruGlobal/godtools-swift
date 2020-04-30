//
//  ArticleAemImportServiceCacheValidation.swift
//  godtools
//
//  Created by Levi Eggert on 4/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticleAemImportServiceCacheValidation {
        
    private static let secondsInOneDay: TimeInterval = 86400

    private let cacheExpirationSeconds: TimeInterval
    
    required init() {
        
        cacheExpirationSeconds = ArticleAemImportServiceCacheValidation.secondsInOneDay * 7
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private func getCacheKey(godToolsResource: GodToolsResource) -> String {
        return String(describing: ArticleAemImportServiceCacheValidation.self) + "." + godToolsResource.resourceId + "." + godToolsResource.languageCode
    }
    
    private func cacheDateKey(godToolsResource: GodToolsResource) -> String {
        return getCacheKey(godToolsResource: godToolsResource) + ".cacheDate"
    }
    
    private func cacheVersionKey(godToolsResource: GodToolsResource) -> String {
        return getCacheKey(godToolsResource: godToolsResource) + ".translationVersion"
    }
    
    func setCacheDate(godToolsResource: GodToolsResource) {
                               
        let cacheDate: Date = Date()

        defaults.set(cacheDate, forKey: cacheDateKey(godToolsResource: godToolsResource))
        defaults.set(NSNumber(value: godToolsResource.translationsVersion), forKey: cacheVersionKey(godToolsResource: godToolsResource))
        
        defaults.synchronize()
    }
    
    func cacheIsValid(godToolsResource: GodToolsResource) -> Bool {
                   
        if let cacheDate = defaults.object(forKey: cacheDateKey(godToolsResource: godToolsResource)) as? Date,
            let version = defaults.object(forKey: cacheVersionKey(godToolsResource: godToolsResource)) as? NSNumber {

            let timeSinceLastCacheDate: TimeInterval = Date().timeIntervalSince(cacheDate)
            let translationVersion: Int16 = version.int16Value
            
            let cacheIsValid: Bool = timeSinceLastCacheDate < cacheExpirationSeconds && godToolsResource.translationsVersion == translationVersion
            
            return cacheIsValid
        }
        
        
                
        return false
    }
}
