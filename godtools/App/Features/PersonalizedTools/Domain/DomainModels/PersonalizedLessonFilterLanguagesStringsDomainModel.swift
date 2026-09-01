//
//  PersonalizedLessonFilterLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/1/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct PersonalizedLessonFilterLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: PersonalizedLessonFilterLanguagesStringsDomainModel {
        return PersonalizedLessonFilterLanguagesStringsDomainModel(navTitle: "")
    }
}
