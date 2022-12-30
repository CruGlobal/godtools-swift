//
//  LanguageDirectionDomainModel+LayoutDirection.swift
//  godtools
//
//  Created by Rachael Skeath on 4/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

extension LanguageDirectionDomainModel {
    
    var layoutDirection: LayoutDirection {
        switch self {
        case .leftToRight:
            return .leftToRight
        case .rightToLeft:
            return .rightToLeft
        }
    }
}
