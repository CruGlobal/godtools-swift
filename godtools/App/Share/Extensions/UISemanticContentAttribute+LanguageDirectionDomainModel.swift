//
//  UISemanticContentAttribute+LanguageDirectionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

extension UISemanticContentAttribute {
    
    static func from(languageDirection: LanguageDirectionDomainModel) -> UISemanticContentAttribute {
        switch languageDirection {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        }
    }
}
