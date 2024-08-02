//
//  LanguageDirectionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum LanguageDirectionDomainModel {
    
    case leftToRight
    case rightToLeft
    
    init(languageModel: LanguageModel) {
        switch languageModel.direction {
        case .leftToRight:
            self = .leftToRight
        case .rightToLeft:
            self = .rightToLeft
        }
    }
}
