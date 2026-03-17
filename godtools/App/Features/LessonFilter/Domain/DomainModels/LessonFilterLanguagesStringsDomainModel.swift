//
//  LessonFilterLanguagesStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct LessonFilterLanguagesStringsDomainModel: Sendable {
    
    let navTitle: String
    
    static var emptyValue: LessonFilterLanguagesStringsDomainModel {
        return LessonFilterLanguagesStringsDomainModel(navTitle: "")
    }
}
