//
//  ArticleAemDownloadGetCacheTimeInterval.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ArticleAemDownloadGetCacheTimeInterval {
    
    init() {
        
    }
    
    func getCacheTimeInterval(cachePolicy: ArticleAemDownloadOperationCachePolicy) -> TimeInterval {
                
        let secondsSinceEpoch: TimeInterval = Date().timeIntervalSince1970
        
        switch cachePolicy {
            
        case .fetchFromCacheUpToNextHour:

            let secondsInOneHour: TimeInterval = 3600
            let timeIntervalRoundedDownToNearestHour: TimeInterval = secondsSinceEpoch - (secondsSinceEpoch.truncatingRemainder(dividingBy: secondsInOneHour))
                        
            return timeIntervalRoundedDownToNearestHour
            
        case .ignoreCache:
            return secondsSinceEpoch
        }
    }
}
