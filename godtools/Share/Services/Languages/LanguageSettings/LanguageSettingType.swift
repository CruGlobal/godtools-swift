//
//  LanguageSettingType.swift
//  godtools
//
//  Created by Levi Eggert on 6/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum LanguageSettingType {
    
    case primary
    case parallel
    
    var key: String {
        switch self {
        case .primary:
            return "kPrimaryLanguageId"
        case .parallel:
            return "kParallelLanguageId"
        }
    }
}
