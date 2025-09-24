//
//  RepositorySyncPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

public protocol RepositorySyncPersistence<DataModelType, QueryType, ExternalObjectType> {
    
    associatedtype DataModelType
    associatedtype QueryType
    associatedtype ExternalObjectType
    
    func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never>
    func getObjectCount() -> Int
    func getObject(id: String) -> DataModelType?
    func getObjects(query: QueryType?) -> [DataModelType]
    func getObjects(ids: [String]) -> [DataModelType]
    func writeObjects(externalObjects: [ExternalObjectType], deleteObjectsNotFoundInExternalObjects: Bool) -> [DataModelType]
    func deleteAllObjects()
}
