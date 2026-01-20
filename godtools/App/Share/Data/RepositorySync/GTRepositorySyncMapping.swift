//
//  GTRepositorySyncMapping.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

protocol GTRepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType> {
        
    associatedtype DataModelType
    associatedtype ExternalObjectType
    associatedtype PersistObjectType
    
    func toDataModel(externalObject: ExternalObjectType) -> DataModelType?
    func toDataModel(persistObject: PersistObjectType) -> DataModelType?
    func toPersistObject(externalObject: ExternalObjectType) -> PersistObjectType?
}
