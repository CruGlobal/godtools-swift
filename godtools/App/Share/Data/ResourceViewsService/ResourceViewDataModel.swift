//
//  ResourceViewDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ResourceViewDataModel: Sendable {
    
    let id: String
    let resourceId: String
    let quantity: Int
    
    func copy(quantity: Int?) -> ResourceViewDataModel {
        return ResourceViewDataModel(
            id: id,
            resourceId: resourceId,
            quantity: quantity ?? self.quantity
        )
    }
}
