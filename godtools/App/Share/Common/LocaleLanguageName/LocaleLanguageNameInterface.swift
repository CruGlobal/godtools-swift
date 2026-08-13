//
//  LocaleLanguageNameInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

protocol LocaleLanguageNameInterface: Sendable {
    
    func getLanguageName(forLanguageCode: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String?
    func getLanguageName(forLocaleId: String, translatedInLanguageId: BCP47LanguageIdentifier?) -> String?
}
