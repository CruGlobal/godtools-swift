//
//  LanguageDataModel+LanguageDirectionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

extension LanguageDataModel {
    
    var languageDirectionDomainModel: LanguageDirectionDomainModel {
        switch direction {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}
