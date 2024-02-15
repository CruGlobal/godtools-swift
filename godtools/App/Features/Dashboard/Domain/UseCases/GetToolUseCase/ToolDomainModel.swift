//
//  ToolDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct ToolDomainModel: ToolListItemDomainModelInterface {
    
    let abbreviation: String
    let bannerImageId: String
    let category: String
    let currentTranslationLanguage: LanguageDomainModel
    let dataModelId: String
    let languageIds: [String]
    let name: String
    
    // TODO: - Remove this once we're done refactoring to pass ToolDomainModels around instead of ResourceModels. See GT-2100. ~Levi
    @available(*, deprecated)
    let resource: ResourceModel
}

extension ToolDomainModel: Equatable {}

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
