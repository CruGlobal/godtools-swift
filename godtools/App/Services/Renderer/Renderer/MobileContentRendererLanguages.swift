//
//  MobileContentRendererLanguages.swift
//  godtools
//
//  Created by Levi Eggert on 10/4/24.
//  Copyright © 2024 Cru. All rights reserved.
//

class MobileContentRendererLanguages {
    
    let languages: [LanguageModel]
    let primaryLanguage: LanguageModel
    
    init(toolTranslations: ToolTranslationsDomainModel) {
        
        languages = toolTranslations.languageTranslationManifests.map {
            $0.language
        }
        
        primaryLanguage = toolTranslations.languageTranslationManifests[0].language
    }
    
    var parallelLanguage: LanguageModel? {
        return languages[safe: 1]
    }
}
