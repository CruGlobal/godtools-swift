//
//  AppLanguageDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AppLanguageDomainModel {
    
    let languageCode: String
    let languageDirection: AppLanguageDomainModel.Direction
}

extension AppLanguageDomainModel {
    enum Direction {
        case leftToRight
        case rightToLeft
    }
}
