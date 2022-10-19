//
//  LessonDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/12/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct LessonDomainModel {
    
    let abbreviation: String
    let bannerImageId: String
    let dataModelId: String
    let description: String
    let languageIds: [String]
    let name: String
}

extension LessonDomainModel {
    
    // TODO: - remove this once we're done refactoring to pass LessonDomainModels around instead of ResourceModels
    init(resource: ResourceModel) {
        abbreviation = resource.abbreviation
        bannerImageId = resource.attrBanner
        dataModelId = resource.id
        languageIds = resource.languageIds
        name = resource.name
        description = resource.resourceDescription        
    }
}

extension LessonDomainModel: Equatable {}

extension LessonDomainModel: Identifiable {
    
    var id: String {
        dataModelId
    }
}

extension LessonDomainModel: LanguageSupportable {
    
    func supportsLanguage(languageId: String) -> Bool {
        if !languageId.isEmpty {
            return languageIds.contains(languageId)
        }
        
        return false
    }
}
