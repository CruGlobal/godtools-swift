//
//  LanguageDirection+SemanticContentAttribute.swift
//  godtools
//
//  Created by Levi Eggert on 4/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

extension LanguageDirection {
    
    var semanticContentAttribute: UISemanticContentAttribute {
        
        switch self {
            case .leftToRight:
                return .forceLeftToRight
            case .rightToLeft:
                return .forceRightToLeft
        }
    }
}
