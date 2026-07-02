//
//  LanguageCodeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum LanguageCodeDomainModel: String, Sendable {
    
    case afrikaans = "af"
    case amharic = "am"
    case arabic = "ar"
    case bangla = "bn"
    case chinese = "zh"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case czech = "cs"
    case english = "en"
    case filipino = "fil"
    case finnish = "fi"
    case french = "fr"
    case german = "de"
    case hausa = "ha"
    case hebrew = "he"
    case hindi = "hi"
    case indonesian = "id"
    case japanese = "ja"
    case korean = "ko"
    case latvian = "lv"
    case nepali = "ne"
    case oromo = "om"
    case portuguese = "pt"
    case romanian = "ro"
    case russian = "ru"
    case spanish = "es"
    case swahili = "sw"
    case urdu = "ur"
    case vietnamese = "vi"
    
    var value: String {
        return rawValue
    }
}
