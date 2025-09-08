//
//  LanguageDataModel+LanguageDirectionDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/25.
//  Copyright © 2025 Cru. All rights reserved.
//

extension LanguageDataModel {
    
    func getLanguageDirection() -> LanguageDirectionDomainModel {
        switch direction {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}
