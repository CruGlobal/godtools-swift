//
//  LanguageModel+Direction.swift
//  godtools
//
//  Created by Levi Eggert on 8/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@available(*, deprecated) // TODO: This will need to be removed and LanguageDomainModel (direction attribute) should be used in place. ~Levi
extension LanguageModel {
    
    var languageDirection: LanguageDirection {
        
        if direction == "rtl" {
            return .rightToLeft
        }
        
        return .leftToRight
    }
}
