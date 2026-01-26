//
//  GTRepositorySyncCachePolicy.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

public enum GTRepositorySyncCachePolicy {
    
    // Fetches remote data and stores remote data to cache.
    // Will not observe changes. Can use returnCacheDataAndFetch if observe changes is needed.
    case fetchIgnoringCacheData(requestPriority: RequestPriority)
    
    // Fetches cached data, doesn't fetch data from remote.
    case returnCacheDataDontFetch(observeChanges: Bool)
    
    // Fetches cached data, if no cached data, fetches data from remote and stores remote data to cache.
    case returnCacheDataElseFetch(requestPriority: RequestPriority, observeChanges: Bool)
    
    // Fetches cached data and fetches remote data and stores remote data to cache.
    // By default will observe changes.
    case returnCacheDataAndFetch(requestPriority: RequestPriority)
}
