//
//  AppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDataModel {
    
    let languageCode: String
    let languageDirection: AppLanguageDataModel.Direction
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
