//
//  AppLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct AppLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: AppLanguagesStringsDomainModel {
        return AppLanguagesStringsDomainModel(navTitle: "")
    }
}
