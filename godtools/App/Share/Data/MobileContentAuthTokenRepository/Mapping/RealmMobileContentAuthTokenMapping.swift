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
    
    func toDataModel(externalObject: MobileContentAuthTokenCodable) -> MobileContentAuthTokenDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmMobileContentAuthToken) -> MobileContentAuthTokenDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentAuthTokenCodable) -> RealmMobileContentAuthToken? {
        return RealmMobileContentAuthToken.createNewFrom(model: externalObject.toModel())
    }
}
