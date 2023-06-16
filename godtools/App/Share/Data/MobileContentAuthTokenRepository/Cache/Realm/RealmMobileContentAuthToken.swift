//
//  RealmMobileContentAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 5/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMobileContentAuthToken: Object {
    
    @objc dynamic var expirationDate: Date?
    @objc dynamic var userId: String = ""
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}
