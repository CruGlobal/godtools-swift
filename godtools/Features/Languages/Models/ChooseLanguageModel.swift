//
//  ChooseLanguageModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ChooseLanguageModel {
    
    let languageId: String
    let languageName: String
    
    init(language: LanguageModel, translateLanguageNameViewModel: TranslateLanguageNameViewModel) {
        languageId = language.id
        languageName = translateLanguageNameViewModel.getTranslatedName(language: language, shouldFallbackToPrimaryLanguageLocale: false)
    }
}
