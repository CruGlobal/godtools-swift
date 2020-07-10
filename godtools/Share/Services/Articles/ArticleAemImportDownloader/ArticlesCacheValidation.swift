//
//  ArticlesCacheValidation.swift
//  godtools
//
//  Created by Levi Eggert on 5/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ArticlesCacheValidation {
        
    private static let secondsInDay: TimeInterval = 86400
    
    private let resourceId: String
    private let languageCode: String
    private let translationVersion: Int
    private let primaryCacheKey: String
    private let cacheExpirationSeconds: TimeInterval = ArticlesCacheValidation.secondsInDay * 7
    
    required init(translationZipFile: TranslationZipFileModel) {
        
        self.resourceId = translationZipFile.resourceId
        self.languageCode = translationZipFile.languageCode
        self.translationVersion = translationZipFile.translationsVersion
        self.primaryCacheKey = String(describing: ArticlesCacheValidation.self) + "." + resourceId + "." + languageCode
    }
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    private var cacheDateKey: String {
        return primaryCacheKey + ".cacheDate"
    }
    
    private var cacheVersionKey: String {
        return primaryCacheKey + ".translationVersion"
    }
    
    private var cachedDate: Date? {
        return defaults.object(forKey: cacheDateKey) as? Date
    }
    
    private var cachedVersion: NSNumber? {
        return defaults.object(forKey: cacheVersionKey) as? NSNumber
    }
    
    func setCached() {
                               
        let cacheDate: Date = Date()

        defaults.set(cacheDate, forKey: cacheDateKey)
        defaults.set(NSNumber(value: translationVersion), forKey: cacheVersionKey)
        
        defaults.synchronize()
    }
    
    var isCached: Bool {
        
        return cachedDate != nil && cachedVersion != nil
    }
    
    var cacheExpired: Bool {
                    
        guard let cacheDate = cachedDate else {
            return true
        }
        
        guard let cacheVersion = cachedVersion else {
            return true
        }
        
        let isExpired: Bool
        
        let timeSinceLastCacheDate: TimeInterval = Date().timeIntervalSince(cacheDate)
        isExpired = timeSinceLastCacheDate >= cacheExpirationSeconds
        
        let versionChanged: Bool = cacheVersion.intValue != translationVersion
        
        return isExpired || versionChanged
    }
}
