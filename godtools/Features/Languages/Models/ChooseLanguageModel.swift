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
    
    init(language: LanguageModel) {
        languageId = language.id
        languageName = LanguageNameViewModel(language: language).name
    }
}
