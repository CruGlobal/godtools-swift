//
//  GlobalActivityAnalyticsCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 2/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol GlobalActivityAnalyticsCacheType {
    
    func getGlobalActivityAnalytics() -> GlobalActivityAnalytics?
    func cacheGlobalActivityAnalytics(globalAnalytics: GlobalActivityAnalytics)
}
