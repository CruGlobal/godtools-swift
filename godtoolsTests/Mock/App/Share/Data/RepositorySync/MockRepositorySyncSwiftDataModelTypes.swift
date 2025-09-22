//
//  MockRepositorySyncSwiftDataModelTypes.swift
//  godtools
//
//  Created by Levi Eggert on 9/20/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import SwiftData

@available(iOS 17, *)
class MockRepositorySyncSwiftDataModelTypes: SwiftDatabaseModelTypesInterface {
    
    init() {
        
    }
    
    func getModelTypes() -> any PersistentModel.Type {
        return MockRepositorySyncSwiftDataObject.self
    }
}
