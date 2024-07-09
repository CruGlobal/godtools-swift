//
//  LocalizationLanguageNameRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/5/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol LocalizationLanguageNameRepositoryInterface {
    
    func getLanguageName(languageId: BCP47LanguageIdentifier, translatedInLanguage: BCP47LanguageIdentifier) -> String?
}
