//
//  UserLessonLanguageFilterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct UserLessonLanguageFilterDataModel {
    
    let createdAt: Date
    let languageId: String
    
    init(realmUserLessonLanguageFilter: RealmUserLessonLanguageFilter) {
        createdAt = realmUserLessonLanguageFilter.createdAt
        languageId = realmUserLessonLanguageFilter.languageId
    }
}
