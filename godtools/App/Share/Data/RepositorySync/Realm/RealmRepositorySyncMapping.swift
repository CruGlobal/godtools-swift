//
//  RealmRepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

open class RealmRepositorySyncMapping<DataModelType, ExternalFetchObjectType, RealmObjectType: Object> {
        
    open func toDataModel(externalObject: ExternalFetchObjectType) -> DataModelType? {
        return nil
    }
    
    open func toDataModel(persistObject: RealmObjectType) -> DataModelType? {
        return nil
    }
    
    open func toPersistObject(externalObject: ExternalFetchObjectType) -> RealmObjectType? {
        return nil
    }
}
