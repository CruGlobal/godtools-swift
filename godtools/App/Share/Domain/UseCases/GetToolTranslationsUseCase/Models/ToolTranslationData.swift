//
//  ToolTranslationData.swift
//  godtools
//
//  Created by Levi Eggert on 5/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ToolTranslationData {
    
    let resource: ResourceModel
    let language: LanguageModel
    let translation: TranslationModel
    let manifestData: Data
    
    init(resource: ResourceModel, language: LanguageModel, translation: TranslationModel, manifestData: Data) {
        
        self.resource = resource
        self.language = language
        self.translation = translation
        self.manifestData = manifestData
    }
}

