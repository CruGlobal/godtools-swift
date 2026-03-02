//
//  RealmMobileContentAuthTokenMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmMobileContentAuthTokenMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentAuthTokenDecodable) -> MobileContentAuthTokenDataModel? {
        return MobileContentAuthTokenDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: RealmMobileContentAuthToken) -> MobileContentAuthTokenDataModel? {
        return MobileContentAuthTokenDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: MobileContentAuthTokenDecodable) -> RealmMobileContentAuthToken? {
        return RealmMobileContentAuthToken.createNewFrom(interface: externalObject)
    }
}
