//
//  FetchLanguageTranslationResultType.swift
//  godtools
//
//  Created by Levi Eggert on 6/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum FetchLanguageTranslationResultType {
    
    case languageSupported
    case languageNotSupportedFallingBackToDeviceLocaleLanguage
    case languageNotSupportedFallingBackToEnglish
    case languageNotSupported
    case unableToLocateDataInCache
}
