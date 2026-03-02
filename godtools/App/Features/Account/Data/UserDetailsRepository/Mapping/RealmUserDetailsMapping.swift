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
        return UserDetailsDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmUserDetails) -> UserDetailsDataModel? {
        return UserDetailsDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: MobileContentApiUsersMeCodable) -> RealmUserDetails? {
        return RealmUserDetails.createNewFrom(interface: externalObject)
    }
}
