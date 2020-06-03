//
//  ResourcesRealmCacheType.swift
//  godtools
//
//  Created by Levi Eggert on 6/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ResourcesRealmCacheType {
    
    func cacheResources(resources: ResourcesJson, complete: @escaping ((_ error: ResourcesRealmCacheError?) -> Void))
}
