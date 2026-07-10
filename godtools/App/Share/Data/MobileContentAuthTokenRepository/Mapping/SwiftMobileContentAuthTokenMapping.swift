//
//  SwiftMobileContentAuthTokenMapping.swift
//  godtools
//
//  Created by Levi Eggert on 2/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftMobileContentAuthTokenMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentAuthTokenCodable) -> MobileContentAuthTokenDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftMobileContentAuthToken) -> MobileContentAuthTokenDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentAuthTokenCodable) -> SwiftMobileContentAuthToken? {
        return SwiftMobileContentAuthToken.createNewFrom(model: externalObject.toModel())
    }
}
