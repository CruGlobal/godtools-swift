//
//  LanguageDirectionDomainModel+UISemanticContentAttribute.swift
//  godtools
//
//  Created by Levi Eggert on 12/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

extension LanguageDirectionDomainModel {
    
    var semanticContentAttribute: UISemanticContentAttribute {
        switch self {
        case .leftToRight:
            return .forceLeftToRight
        case .rightToLeft:
            return .forceRightToLeft
        }
    }
}
