//
//  TranslatableLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 12/14/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

protocol TranslatableLanguage {
    
    var languageCode: String { get }
    var localeId: BCP47LanguageIdentifier { get }
    var fallbackName: String { get }
    var regionCode: String? { get }
    var scriptCode: String? { get }
}
