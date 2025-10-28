//
//  MockSwiftDataSchemaV1.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
enum MockSwiftDataSchemaV1: VersionedSchema {
    
    static let versionIdentifier = Schema.Version(1, 0, 0)
        
    static var models: [any PersistentModel.Type] {
        return [
            MockRepositorySyncSwiftDataObject.self
        ]
    }
}
