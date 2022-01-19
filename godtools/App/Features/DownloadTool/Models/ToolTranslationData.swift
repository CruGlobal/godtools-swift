//
//  ToolTranslationData.swift
//  godtools
//
//  Created by Levi Eggert on 1/16/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolTranslationData {
    
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
