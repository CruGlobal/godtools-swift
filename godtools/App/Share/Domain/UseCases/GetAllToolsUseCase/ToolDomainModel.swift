//
//  ToolDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolDomainModel {
    
    let attrBanner: String
    let attrDefaultOrder: Int
    let dataModelId: String
    
    // TODO: - remove this once we're done refactoring to pass ToolDomainModels around instead of ResourceModels
    let resource: ResourceModel
}

extension ToolDomainModel {
    
    init(resource: ResourceModel) {
        attrBanner = resource.attrBanner
        attrDefaultOrder = resource.attrDefaultOrder
        dataModelId = resource.id
        
        self.resource = resource
    }
}

extension ToolDomainModel: Identifiable {
    
    var id: String {
        dataModelId
    }
}
