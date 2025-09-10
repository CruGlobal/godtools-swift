//
//  RepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

open class RepositorySyncMapping<DataModelType, ExternalFetchObjectType, RealmObjectType: Object> {
        
    func toDataModel(externalObject: ExternalFetchObjectType) -> DataModelType? {
        return nil
    }
    
    func toDataModel(persistObject: RealmObjectType) -> DataModelType? {
        return nil
    }
    
    func toPersistObject(dataModel: DataModelType) -> RealmObjectType? {
        return nil
    }
}
