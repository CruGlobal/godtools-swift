//
//  RealmFavoritedResource.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFavoritedResource: Object {
    
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var resourceId: String = ""
    @objc dynamic var position: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}
