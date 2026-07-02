//
//  TranslationCodable+ToModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/16/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

extension TranslationCodable {
    
    func toModel() -> TranslationDataModel {
        return TranslationDataModel(
            id: id,
            isPublished: isPublished,
            languageDataModel: languageDataModel,
            manifestName: manifestName,
            resourceDataModel: resourceDataModel,
            toolDetailsBibleReferences: toolDetailsBibleReferences,
            toolDetailsConversationStarters: toolDetailsConversationStarters,
            toolDetailsOutline: toolDetailsOutline,
            translatedDescription: translatedDescription,
            translatedName: translatedName,
            translatedTagline: translatedTagline,
            type: type,
            version: version
        )
    }
    
    var resourceDataModel: ResourceDataModel? {
        
        guard let resource = resource else {
            return nil
        }
        
        return resource.toModel()
    }
    
    var languageDataModel: LanguageDataModel? {
        
        guard let language = language else {
            return nil
        }
        
        return language.toModel()
    }
}
