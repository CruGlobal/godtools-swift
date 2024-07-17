//
//  RealmUserToolLanguageFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserToolLanguageFilter: Object {
    
    static let filterId = "userToolLanguageFilter"
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var languageId: String = ""
    @objc dynamic var filterId: String = RealmUserToolLanguageFilter.filterId
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}
