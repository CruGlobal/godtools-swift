//
//  RealmUserLessonLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 7/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserLessonLanguageFilter: Object {
    
    static let filterId = "userLessonLanguageFilter"
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var languageId: String = ""
    @objc dynamic var filterId: String = RealmUserLessonLanguageFilter.filterId
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}
