//
//  FailedResourceViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct FailedResourceViewModel: FailedResourceViewModelType {
    
    let resourceId: String
    let failedViewsCount: Int
    
    init(model: FailedResourceViewModelType) {
        
        resourceId = model.resourceId
        failedViewsCount = model.failedViewsCount
    }
}
