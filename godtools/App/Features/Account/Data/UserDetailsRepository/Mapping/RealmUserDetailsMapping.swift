//
//  RealmUserDetailsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmUserDetailsMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentApiUsersMeCodable) -> UserDetailsDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmUserDetails) -> UserDetailsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentApiUsersMeCodable) -> RealmUserDetails? {
        return RealmUserDetails.createNewFrom(model: externalObject.toModel())
    }
}
