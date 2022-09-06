//
//  GetToolUseCase.swift
//  godtools
//
//  Created by Rachael Skeath on 8/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetToolUseCase {
    
    func getTool(resource: ResourceModel) -> ToolDomainModel {
        
        return ToolDomainModel(
            bannerImageId: resource.attrBanner,
            category: resource.attrCategory,
            dataModelId: resource.id,
            languageIds: resource.languageIds,
            name: resource.name,
            resource: resource
        )
    }
}
