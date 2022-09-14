//
//  ToolDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 8/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

struct ToolDomainModel {
    
    // TODO: - finish mapping necessary attributes in GT-1777
    let bannerImageId: String
    let category: String
    let currentTranslationPublisher: AnyPublisher<CurrentToolTranslationDomainModel, Never>
    let dataModelId: String
    let languageIds: [String]
    let namePublisher: AnyPublisher<String, Never>
    
    // TODO: - remove this once we're done refactoring to pass ToolDomainModels around instead of ResourceModels
    let resource: ResourceModel
}

extension ToolDomainModel {
    
    // TODO: - remove this once we're done refactoring.  (Should be using GetToolUseCase if we need to map from ResourceModel to ToolDomainModel)
    init(resource: ResourceModel) {
        bannerImageId = resource.attrBanner
        category = resource.attrCategory
        currentTranslationPublisher = Just(.englishFallback(translation: nil)).eraseToAnyPublisher()
        dataModelId = resource.id
        languageIds = resource.languageIds
        namePublisher = Just(resource.name).eraseToAnyPublisher()
        
        self.resource = resource
    }
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
