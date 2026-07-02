//
//  SwiftUserDetailsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftUserDetailsMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentApiUsersMeCodable) -> UserDetailsDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftUserDetails) -> UserDetailsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentApiUsersMeCodable) -> SwiftUserDetails? {
        return SwiftUserDetails.createNewFrom(model: externalObject.toModel())
    }
}
