//
//  MockRepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockRepositorySyncMapping: RepositorySyncMapping<MockRepositorySyncDataModel, MockRepositorySyncDataModel, MockRepositorySyncRealmObject> {

    override func toDataModel(persistObject: MockRepositorySyncRealmObject) -> MockRepositorySyncDataModel? {
        
        return MockRepositorySyncDataModel(
            id: persistObject.id,
            name: persistObject.name
        )
    }
    
    override func toPersistObject(externalObject: MockRepositorySyncDataModel) -> MockRepositorySyncRealmObject? {
        
        let realmObject = MockRepositorySyncRealmObject()
        
        realmObject.id = externalObject.id
        realmObject.name = externalObject.name
        
        return realmObject
    }
}
