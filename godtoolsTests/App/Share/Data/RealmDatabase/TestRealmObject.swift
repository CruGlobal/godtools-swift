//
//  TestRealmObject.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
@testable import godtools

class TestRealmObject: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

