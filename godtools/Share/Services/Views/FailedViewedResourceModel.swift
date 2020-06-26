//
//  FailedViewedResourceModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FailedViewedResourceModel: FailedViewedResourceModelType {
    
    let resourceId: String
    let failedViewsCount: Int
    
    init(realmModel: RealmFailedViewedResource) {
        
        resourceId = realmModel.resourceId
        failedViewsCount = realmModel.failedViewsCount
    }
}
