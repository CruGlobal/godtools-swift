//
//  GlobalAnalyticsCacheObject.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmGlobalAnalytics: Object {
    
    @objc dynamic var countries: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var id: String = ""
    @objc dynamic var gospelPresentations: Int = 0
    @objc dynamic var launches: Int = 0
    @objc dynamic var type: String = ""
    @objc dynamic var users: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
