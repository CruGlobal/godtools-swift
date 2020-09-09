//
//  LanguageModel+Direction.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension LanguageModel {
    
    enum LanguageDirection: String {
        
        case leftToRight = "ltr"
        case rightToLeft = "rtl"
    }
    
    var languageDirection: LanguageModel.LanguageDirection {
        return LanguageDirection(rawValue: direction) ?? .leftToRight
    }
}
