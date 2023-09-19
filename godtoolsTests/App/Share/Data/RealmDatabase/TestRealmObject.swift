//
//  TestRealmObject.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class TestRealmObject: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

