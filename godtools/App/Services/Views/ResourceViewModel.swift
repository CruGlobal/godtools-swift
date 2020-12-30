//
//  ResourceViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourceViewModel: ResourceViewModelType {
    
    let resourceId: String
    let quantity: Int
    
    init(resourceId: String) {
        
        self.resourceId = resourceId
        self.quantity = 1
    }
    
    init(model: ResourceViewModelType) {
        
        resourceId = model.resourceId
        quantity = model.quantity
    }
}
