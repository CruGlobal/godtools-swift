//
//  ToolDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolDomainModel {
    
    let abbreviation: String
    let bannerImageId: String
    let category: String
    let currentTranslation: CurrentToolTranslationDomainModel
    let dataModelId: String
    let languageIds: [String]
    let name: String
    
    // TODO: - remove this once we're done refactoring to pass ToolDomainModels around instead of ResourceModels
    let resource: ResourceModel
}

extension ToolDomainModel: Identifiable {
    
    var id: String {
        dataModelId
    }
}

extension ToolDomainModel: LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        
        return false
    }
}
