//
//  MockTranslatableLanguage.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 7/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

struct MockTranslatableLanguage: TranslatableLanguage {
    
    let languageCode: String
    let localeId: BCP47LanguageIdentifier
    let fallbackName: String
    let regionCode: String?
    let scriptCode: String?
}
