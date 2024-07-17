//
//  TestRealmObjectMapping.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 5/3/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct TestRealmObjectMapping {
    
    let id: String
    let name: String
    
    init(realmObject: TestRealmObject) {
        
        id = realmObject.id
        name = realmObject.name
    }
}
