//
//  LayoutDirection+LanguageDirectionDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 4/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

extension LayoutDirection {
    
    static func from(languageDirection: LanguageDirectionDomainModel) -> LayoutDirection {
        switch languageDirection {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}
