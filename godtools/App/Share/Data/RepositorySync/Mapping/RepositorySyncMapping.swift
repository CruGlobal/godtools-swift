//
//  RepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData

@available(iOS 17, *)
open class RepositorySyncMapping<DataModelType, ExternalFetchObjectType, SwiftDataObjectType: IdentifiableSwiftDataObject> {
        
    open func toDataModel(externalObject: ExternalFetchObjectType) -> DataModelType? {
        return nil
    }
    
    open func toDataModel(persistObject: SwiftDataObjectType) -> DataModelType? {
        return nil
    }
    
    open func toPersistObject(externalObject: ExternalFetchObjectType) -> SwiftDataObjectType? {
        return nil
    }
}
