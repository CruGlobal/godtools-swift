//
//  LanguageModel+Direction.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

extension LanguageModel {
    
    var languageDirection: LanguageDirection {
        
        if direction == "rtl" {
            return .rightToLeft
        }
        
        return .leftToRight
    }
}
