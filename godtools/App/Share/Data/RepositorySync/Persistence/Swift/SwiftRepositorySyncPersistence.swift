//
//  SwiftRepositorySyncPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import Combine

@available(iOS 17, *)
class SwiftRepositorySyncPersistence<DataModelType, ExternalObjectType, PersistObjectType: IdentifiableSwiftDataObject>: RepositorySyncPersistence {
    
    private let swiftDatabase: SwiftDatabase
    private let dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>
    private let userInfoKeyPrependNotification: String = "RepositorySync.notificationKey.prepend"
    private let userInfoKeyEntityName: String = "RepositorySync.notificationKey.entityName"
    private let entityName: String
    
    init(swiftDatabase: SwiftDatabase, dataModelMapping: any RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>) {
        
        self.swiftDatabase = swiftDatabase
        self.dataModelMapping = dataModelMapping
        
        if #available(iOS 18.0, *) {
            entityName = Schema.entityName(for: PersistObjectType.self)
        }
        else {
            // TODO: Can remove once supporting iOS 18 and up. ~Levi
            entityName = PersistObjectType.entityName
        }
    }
}

// MARK: - Observe

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
    func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        
        return observeSwiftDataCollectionChangesPublisher()
    }
    
    private func observeSwiftDataCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
                
        let swiftDatabaseRef: SwiftDatabase = self.swiftDatabase
        let swiftDatabaseEntityNameRef: String = self.entityName
        let userInfoKeyPrependNotification: String = self.userInfoKeyPrependNotification
        let userInfoKeyEntityName: String = self.userInfoKeyEntityName
        
        // NOTE: Prepends a notification on first observation in order to trigger changes on first observation.
        let prependNotification = Notification(
            name: ModelContext.didSave,
            object: swiftDatabaseRef.openContext(),
            userInfo: [
                userInfoKeyPrependNotification: true,
                userInfoKeyEntityName: swiftDatabaseEntityNameRef
            ]
        )
        
        return NotificationCenter
            .default
            .publisher(for: ModelContext.didSave)
            .prepend(prependNotification)
            .compactMap { (notification: Notification) in
                                                
                let swiftDatabaseConfigName: String = swiftDatabaseRef.configName
                let fromContextConfigurations: Set<ModelConfiguration> = (notification.object as? ModelContext)?.container.configurations ?? Set<ModelConfiguration>()
                let fromConfigNames: [String] = fromContextConfigurations.map { $0.name }
                let isSameContainer: Bool = fromConfigNames.contains(swiftDatabaseConfigName)
                
                let userInfo: [AnyHashable: Any] = notification.userInfo ?? Dictionary()
                let isPrepend: Bool = userInfo[userInfoKeyPrependNotification] as? Bool ?? false
                let prependEntityNameMatchesSwiftDatabaseEntityName: Bool = swiftDatabaseEntityNameRef == userInfo[userInfoKeyEntityName] as? String
                
                if isPrepend && prependEntityNameMatchesSwiftDatabaseEntityName && isSameContainer {
                    
                    return Void()
                }
                else if isSameContainer,
                        let changedEntityNamesSet = Self.getNotificationChangedEntityNames(notification: notification),
                        changedEntityNamesSet.contains(swiftDatabaseEntityNameRef) {
                    
                    return Void()
                }
                
                return nil
            }
            .eraseToAnyPublisher()
    }
    
    private static func getNotificationChangedEntityNames(notification: Notification) -> Set<String>? {
        
        let userInfo: [AnyHashable: Any]? = notification.userInfo
        
        guard let userInfo = userInfo else {
            return nil
        }
        
        let insertedIds = userInfo[
            ModelContext.NotificationKey.insertedIdentifiers.rawValue
        ] as? [PersistentIdentifier]
        ?? Array()
        
        let deletedIds = userInfo[
            ModelContext.NotificationKey.deletedIdentifiers.rawValue
        ] as? [PersistentIdentifier]
        ?? Array()
        
        let updatedIds = userInfo[
            ModelContext.NotificationKey.updatedIdentifiers.rawValue
        ] as? [PersistentIdentifier]
        ?? Array()
        
        let allIds: [PersistentIdentifier] = insertedIds + deletedIds + updatedIds
        
        guard allIds.count > 0 else {
            return nil
        }
        
        let entityNames: [String] = allIds.map {
            $0.entityName
        }
        
        let changedEntityNamesSet: Set<String> = Set(entityNames)
        
        return changedEntityNamesSet
    }
}

// MARK: Read

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
    func getObjectCount() -> Int {
        return swiftDatabase.getObjectCount(
            query: SwiftDatabaseQuery<PersistObjectType>(
                fetchDescriptor: FetchDescriptor<PersistObjectType>()
            )
        )
    }
    
    func getObject(id: String) -> DataModelType? {
        
        let idPredicate = #Predicate<PersistObjectType> { object in
            object.id == id
        }
        
        let query = SwiftDatabaseQuery.filter(filter: idPredicate)
        
        return getObjects(query: query).first
    }
    
    func getObjects() -> [DataModelType] {
        
        return getObjects(query: nil)
    }
    
    func getObjects(query: SwiftDatabaseQuery<PersistObjectType>? = nil) -> [DataModelType] {
        
        let context: ModelContext = swiftDatabase.openContext()
        
        let objects: [PersistObjectType] = swiftDatabase.getObjects(
            context: context,
            query: query
        )
        
        let dataModels: [DataModelType] = objects.compactMap { object in
            self.dataModelMapping.toDataModel(persistObject: object)
        }
        
        return dataModels
    }
    
    func getObjects(ids: [String]) -> [DataModelType] {
        
        let query = SwiftDatabaseQuery.filter(filter: getObjectsByIdsFilter(ids: ids))
        
        return getObjects(query: query)
    }
    
    private func getNumberOfObjects(query: SwiftDatabaseQuery<PersistObjectType>?) -> Int {
        
        return swiftDatabase.getObjectCount(query: query)
    }
    
    private func getObjectsByIdsFilter(ids: [String]) -> Predicate<PersistObjectType> {
        let filter = #Predicate<PersistObjectType> { object in
            ids.contains(object.id)
        }
        return filter
    }
}

// MARK: - Write

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
    func writeObjects(externalObjects: [ExternalObjectType], deleteObjectsNotFoundInExternalObjects: Bool = false) -> [DataModelType] {
                
        let context: ModelContext = swiftDatabase.openContext()
        
        var dataModels: [DataModelType] = Array()
        
        var objectsToAdd: [PersistObjectType] = Array()
        
        // store all objects in the collection
        var objectsToRemove: [PersistObjectType]
        
        if deleteObjectsNotFoundInExternalObjects {
            // store all objects in the collection
            objectsToRemove = swiftDatabase.getObjects(context: context, query: nil)
        }
        else {
            objectsToRemove = Array()
        }
        
        for externalObject in externalObjects {

            if let dataModel = dataModelMapping.toDataModel(externalObject: externalObject) {
                dataModels.append(dataModel)
            }
            
            if let swiftDataObject = dataModelMapping.toPersistObject(externalObject: externalObject) {
                
                objectsToAdd.append(swiftDataObject)
                
                // added swift data object can be removed from this list so it won't be deleted from swift data
                if deleteObjectsNotFoundInExternalObjects, let index = objectsToRemove.firstIndex(where: { $0.id == swiftDataObject.id }) {
                    objectsToRemove.remove(at: index)
                }
            }
        }
        
        do {
            try swiftDatabase.saveObjects(
                context: context,
                objectsToAdd: objectsToAdd,
                objectsToRemove: objectsToRemove
            )
        }
        catch let error {
            assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
        }
        
        return dataModels
    }
}

// MARK: - Delete

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
    func deleteAllObjects() {
        
        swiftDatabase.deleteAllObjects()
    }
}
