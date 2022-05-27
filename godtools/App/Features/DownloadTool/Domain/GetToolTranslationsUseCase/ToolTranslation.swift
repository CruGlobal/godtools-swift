//
//  ToolTranslation.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolTranslation {
    
    let resource: ResourceModel
    let language: LanguageModel
    let translation: TranslationModel
    let translationManifestData: TranslationManifestData
    
    required init(resource: ResourceModel, language: LanguageModel, translation: TranslationModel, translationManifestData: TranslationManifestData) {
        
        self.resource = resource
        self.language = language
        self.translation = translation
        self.translationManifestData = translationManifestData
    }
}
