//
//  MockRepositorySyncSwiftDataObject.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import SwiftData
import RepositorySync

@available(iOS 17.4, *)
@Model
class MockRepositorySyncSwiftDataObject: IdentifiableSwiftDataObject {
    
    @Attribute(.unique) var id: String = ""
    var name: String = ""
    
    init() {
        
    }
}
