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
        return MobileContentAuthTokenDataModel(interface: externalObject)
    }
    
    func toDataModel(persistObject: SwiftMobileContentAuthToken) -> MobileContentAuthTokenDataModel? {
        return MobileContentAuthTokenDataModel(interface: persistObject)
    }
    
    func toPersistObject(externalObject: MobileContentAuthTokenDecodable) -> SwiftMobileContentAuthToken? {
        return SwiftMobileContentAuthToken.createNewFrom(interface: externalObject)
    }
}
