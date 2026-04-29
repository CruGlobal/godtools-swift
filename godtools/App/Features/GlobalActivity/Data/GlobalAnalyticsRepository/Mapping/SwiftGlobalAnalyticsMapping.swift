//
//  SwiftGlobalAnalyticsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/24/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

@available(iOS 17.4, *)
final class SwiftGlobalAnalyticsMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentGlobalAnalyticsCodable) -> GlobalAnalyticsDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: SwiftGlobalAnalytics) -> GlobalAnalyticsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentGlobalAnalyticsCodable) -> SwiftGlobalAnalytics? {
        return SwiftGlobalAnalytics.createNewFrom(model: externalObject.toModel())
    }
}
