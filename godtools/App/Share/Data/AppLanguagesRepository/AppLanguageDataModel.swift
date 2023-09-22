//
//  AppLanguageDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDataModel {
    
    let direction: AppLanguageDataModel.Direction
    let languageCode: String
}

extension AppLanguageDataModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
