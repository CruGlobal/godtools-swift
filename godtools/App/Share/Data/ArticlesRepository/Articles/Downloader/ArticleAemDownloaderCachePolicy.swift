//
//  ArticleAemDownloaderCachePolicy.swift
//  godtools
//
//  Created by Levi Eggert on 3/28/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum ArticleAemDownloaderCachePolicy {
    
    case fetchFromCacheUpToNextHour
    case ignoreCache
}

extension ArticleAemDownloaderCachePolicy {
    
    func getCacheTimeInterval() -> TimeInterval {
                
        let secondsSinceEpoch: TimeInterval = Date().timeIntervalSince1970
        
        switch self {
            
        case .fetchFromCacheUpToNextHour:

            let secondsInOneHour: TimeInterval = 3600
            let timeIntervalRoundedDownToNearestHour: TimeInterval = secondsSinceEpoch - (secondsSinceEpoch.truncatingRemainder(dividingBy: secondsInOneHour))
                        
            return timeIntervalRoundedDownToNearestHour
            
        case .ignoreCache:
            return secondsSinceEpoch
        }
    }
}
