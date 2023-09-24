//
//  LanguageCode.swift
//  godtools
//
//  Created by Rachael Skeath on 7/25/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum LanguageCode: String {
    
    case arabic = "ar"
    case chinese = "zh"
    case english = "en"
    case french = "fr"
    case hebrew = "he"
    case latvian = "lv"
    case russian = "ru"
    case spanish = "es"
    case vietnamese = "vi"
    
    var value: String {
        return rawValue
    }
}
