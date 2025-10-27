//
//  MockRepositorySyncRealmObject.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import RealmSwift

class MockRepositorySyncRealmObject: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
