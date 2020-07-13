//
//  LanguageDirection.swift
//  godtools
//
//  Created by Levi Eggert on 6/24/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum LanguageDirection: String {
    
    case leftToRight = "ltr"
    case rightToLeft = "rtl"
    
    static func direction(language: LanguageModelType) -> LanguageDirection {
        
        if let direction = LanguageDirection(rawValue: language.direction) {
            return direction
        }
        
        return .leftToRight
    }
}
