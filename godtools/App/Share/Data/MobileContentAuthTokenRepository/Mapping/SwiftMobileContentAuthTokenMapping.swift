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
    
    func toDataModel(externalObject: MobileContentAuthTokenDecodable) -> MobileContentAuthTokenDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftMobileContentAuthToken) -> MobileContentAuthTokenDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentAuthTokenDecodable) -> SwiftMobileContentAuthToken? {
        return SwiftMobileContentAuthToken.createNewFrom(model: externalObject.toModel())
    }
}
