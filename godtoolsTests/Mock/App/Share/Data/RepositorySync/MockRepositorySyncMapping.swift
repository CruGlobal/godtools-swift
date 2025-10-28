//
//  MockRepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools

@available(iOS 17, *)
class MockRepositorySyncMapping: RepositorySyncMapping {

    func toDataModel(externalObject: MockRepositorySyncDataModel) -> MockRepositorySyncDataModel? {
        
        return externalObject
    }
    
    func toDataModel(persistObject: MockRepositorySyncSwiftDataObject) -> MockRepositorySyncDataModel? {
        
        return MockRepositorySyncDataModel(
            id: persistObject.id,
            name: persistObject.name
        )
    }
    
    func toPersistObject(externalObject: MockRepositorySyncDataModel) -> MockRepositorySyncSwiftDataObject? {
        
        let object = MockRepositorySyncSwiftDataObject()
        
        object.id = externalObject.id
        object.name = externalObject.name
        
        return object
    }
}
