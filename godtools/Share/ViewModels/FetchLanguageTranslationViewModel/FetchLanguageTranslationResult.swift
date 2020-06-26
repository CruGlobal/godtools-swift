//
//  FetchLanguageTranslationResult.swift
//  godtools
//
//  Created by Levi Eggert on 6/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class FetchLanguageTranslationResult {
    
    let resourceId: String
    let language: LanguageModel?
    let translation: TranslationModel?
    let type: FetchLanguageTranslationResultType
    
    required init(resourceId: String, language: LanguageModel?, translation: TranslationModel?, type: FetchLanguageTranslationResultType) {
        
        self.resourceId = resourceId
        self.language = language
        self.translation = translation
        self.type = type
    }
}
