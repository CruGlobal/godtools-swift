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
    let manifestFileName: String
    let manifestData: Data
    
    init(resource: ResourceModel, language: LanguageModel, translation: TranslationModel, manifestFileName: String, manifestData: Data) {
        
        self.resource = resource
        self.language = language
        self.translation = translation
        self.manifestFileName = manifestFileName
        self.manifestData = manifestData
    }
}

