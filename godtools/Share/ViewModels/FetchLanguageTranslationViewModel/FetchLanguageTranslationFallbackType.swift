//
//  FetchLanguageTranslationFallbackType.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FetchLanguageTranslationFallbackType {
    
    case deviceLocaleLanguage
    case englishLanguage
    
    static let all: [FetchLanguageTranslationFallbackType] = [.deviceLocaleLanguage, .englishLanguage]
}
