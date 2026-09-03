//
//  PersonalizedToolFilterLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/3/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedToolFilterLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: PersonalizedToolFilterLanguagesStringsDomainModel {
        return PersonalizedToolFilterLanguagesStringsDomainModel(navTitle: "")
    }
}
