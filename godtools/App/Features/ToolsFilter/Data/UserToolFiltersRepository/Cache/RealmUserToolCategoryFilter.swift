//
//  RealmUserToolCategoryFilter.swift
//  godtools
//
//  Created by Rachael Skeath on 4/1/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserToolCategoryFilter: Object {
    
    static let filterId = "userToolCategoryFilter"
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var categoryId: String = ""
    @objc dynamic var filterId: String = RealmUserToolCategoryFilter.filterId
    
    override static func primaryKey() -> String? {
        return "filterId"
    }
}
