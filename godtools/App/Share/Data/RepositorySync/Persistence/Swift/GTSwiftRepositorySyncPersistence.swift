//
//  GTSwiftRepositorySyncPersistence.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import SwiftData
import Combine
import RepositorySync

@available(iOS 17.4, *)
class GTSwiftRepositorySyncPersistence<DataModelType, ExternalObjectType, PersistObjectType: IdentifiableSwiftDataObject>: GTRepositorySyncPersistence {
    
    private let dataModelMapping: any GTRepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>
    private let userInfoKeyPrependNotification: String = "RepositorySync.notificationKey.prepend"
    private let userInfoKeyEntityName: String = "RepositorySync.notificationKey.entityName"
    private let entityName: String
    
    let swiftDatabase: SwiftDatabase
    
    init(swiftDatabase: SwiftDatabase, dataModelMapping: any GTRepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>) {
        
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

@available(iOS 17.4, *)
extension GTSwiftRepositorySyncPersistence {
    
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
                                                
                let swiftDatabaseConfigName: String = swiftDatabaseRef.container.configName
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

@available(iOS 17.4, *)
extension GTSwiftRepositorySyncPersistence {
    
    func getObjectCount() -> Int {
        return getNumberOfObjects(query: nil)
    }
    
    func getObjectCount(query: SwiftDatabaseQuery<PersistObjectType>?) -> Int {
        return getNumberOfObjects(query: query)
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
        
        let objects: [PersistObjectType] = swiftDatabase.read.objectsNonThrowing(
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
        
        let query: SwiftDatabaseQuery<PersistObjectType> = query ?? SwiftDatabaseQuery<PersistObjectType>(fetchDescriptor: FetchDescriptor<PersistObjectType>())
        
        return swiftDatabase.read.objectCountNonThrowing(
            context: swiftDatabase.openContext(),
            query: query
        )
    }
    
    private func getObjectsByIdsFilter(ids: [String]) -> Predicate<PersistObjectType> {
        let filter = #Predicate<PersistObjectType> { object in
            ids.contains(object.id)
        }
        return filter
    }
}

// MARK: - Write

@available(iOS 17.4, *)
extension GTSwiftRepositorySyncPersistence {
    
    func writeObjects(externalObjects: [ExternalObjectType], deleteObjectsNotFoundInExternalObjects: Bool = false) -> [DataModelType] {
                
        let context: ModelContext = swiftDatabase.openContext()
        
        var dataModels: [DataModelType] = Array()
        
        var objectsToAdd: [PersistObjectType] = Array()
        
        // store all objects in the collection
        var objectsToRemove: [PersistObjectType]
        
        if deleteObjectsNotFoundInExternalObjects {
            // store all objects in the collection
            objectsToRemove = swiftDatabase.read.objectsNonThrowing(context: context, query: nil)
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
            try swiftDatabase.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: objectsToRemove, insertObjects: objectsToAdd)
            )
        }
        catch let error {
            assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
        }
        
        return dataModels
    }
}

// MARK: - Delete

@available(iOS 17.4, *)
extension GTSwiftRepositorySyncPersistence {
    
    func deleteAllObjects() {
                
        let context: ModelContext = swiftDatabase.openContext()
        
        let objectsToRemove: [PersistObjectType] = swiftDatabase.read.objectsNonThrowing(context: context, query: nil)
        
        do {
            try swiftDatabase.write.context(
                context: context,
                writeObjects: WriteSwiftObjects(deleteObjects: objectsToRemove, insertObjects: nil)
            )
        }
        catch let error {
            assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
        }
    }
}
