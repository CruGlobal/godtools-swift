//
//  RepositorySyncCachePolicy.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RequestOperation

public enum RepositorySyncCachePolicy {
    
    // Fetches remote data and stores remote data to cache.
    case fetchIgnoringCacheData(requestPriority: RequestPriority)
    
    // Fetches cached data, doesn't fetch data from remote.
    case returnCacheDataDontFetch
    
    // Fetches cached data, if no cached data, fetches data from remote and stores remote data to cache.
    case returnCacheDataElseFetch(requestPriority: RequestPriority)
    
    // Fetches cached data and fetches remote data and stores remote data to cache.
    case returnCacheDataAndFetch(requestPriority: RequestPriority)
}
