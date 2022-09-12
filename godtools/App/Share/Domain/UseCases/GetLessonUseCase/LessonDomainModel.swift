//
//  LessonDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct LessonDomainModel {
    
    let bannerImageId: String
    let dataModelId: String
    let name: String
    
    // TODO: - remove this once we're done refactoring to pass LessonDomainModels around instead of ResourceModels
    let resource: ResourceModel
}

extension LessonDomainModel {
    
    // TODO: - remove this once we're done refactoring to pass LessonDomainModels around instead of ResourceModels
    init(resource: ResourceModel) {
        bannerImageId = resource.attrBanner
        dataModelId = resource.id
        name = resource.name
        
        self.resource = resource
    }
}

extension LessonDomainModel: Identifiable {
    
    var id: String {
        dataModelId
    }
}
