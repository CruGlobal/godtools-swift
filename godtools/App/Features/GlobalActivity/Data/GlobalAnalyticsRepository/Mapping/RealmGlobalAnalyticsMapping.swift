//
//  RealmGlobalAnalyticsMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/5/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RepositorySync

final class RealmGlobalAnalyticsMapping: Mapping {
    
    func toDataModel(externalObject: MobileContentGlobalAnalyticsCodable) -> GlobalAnalyticsDataModel? {
        return externalObject.toModel()
    }
    
    func toDataModel(persistObject: RealmGlobalAnalytics) -> GlobalAnalyticsDataModel? {
        return persistObject.toModel()
    }
    
    func toPersistObject(externalObject: MobileContentGlobalAnalyticsCodable) -> RealmGlobalAnalytics? {
        return RealmGlobalAnalytics.createNewFrom(model: externalObject.toModel())
    }
}
