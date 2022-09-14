//
//  CurrentToolTranslationDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 9/14/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum CurrentToolTranslationDomainModel {
    case primaryLanguage(language: LanguageDomainModel, translation: TranslationModel)
    case englishFallback(translation: TranslationModel?)
}
