//
//  RepositorySyncCachePolicy.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

public enum RepositorySyncCachePolicy {
    
    case fetchIgnoringCacheData // fetches remote data and stores remote data to cache ( Is there a use for this? ) ~Levi
    case returnCacheDataDontFetch // fetches cached data, doesn't fetch data from remote
    case returnCacheDataElseFetch // fetches cached data, if no cached data, fetches data from remote and stores remote data to cache
    case returnCacheDataAndFetch // fetches cached data and fetches remote data and stores remote data to cache
}
