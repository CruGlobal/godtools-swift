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
    private let dataModelMapping: RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>
    private let userInfoKeyPrependNotification: String = "RepositorySync.notificationKey.prepend"
    private let userInfoKeyEntityName: String = "RepositorySync.notificationKey.entityName"
    private let entityName: String
    
    init(swiftDatabase: SwiftDatabase, dataModelMapping: RepositorySyncMapping<DataModelType, ExternalObjectType, PersistObjectType>) {
        
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
    
    func getCount() -> Int {
        
        return getNumberOfObjects(query: nil)
    }
    
    func getObject(id: String) -> DataModelType? {
        
        let idPredicate = #Predicate<PersistObjectType> { object in
            object.id == id
        }
        
        let query = SwiftDatabaseQuery.filter(filter: idPredicate)
        
        return getObjects(query: query).first
    }
    
    func getObjects(query: SwiftDatabaseQuery<PersistObjectType>? = nil) -> [DataModelType] {
        
        let context: ModelContext = swiftDatabase.openContext()
        
        let objects: [PersistObjectType] = getPersistedObjects(
            context: context,
            query: query
        )
        
        let dataModels: [DataModelType] = objects.compactMap { object in
            self.dataModelMapping.toDataModel(persistObject: object)
        }
        
        return dataModels
    }
    
    func getObjects(ids: [String]) -> [DataModelType] {
        
        let filter = #Predicate<PersistObjectType> { object in
            ids.contains(object.id)
        }
        
        let query = SwiftDatabaseQuery.filter(filter: filter)
        
        return getObjects(query: query)
    }
    
    private func getNumberOfObjects(query: SwiftDatabaseQuery<PersistObjectType>?) -> Int {
        
        do {
            return try swiftDatabase
                .openContext()
                .fetchCount(
                    getFetchDescriptor(query: query)
                )
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return 0
        }
    }
    
    private func getFetchDescriptor(query: SwiftDatabaseQuery<PersistObjectType>?) -> FetchDescriptor<PersistObjectType> {
        
        return query?.fetchDescriptor ?? FetchDescriptor<PersistObjectType>()
    }
    
    private func getPersistedObjects(context: ModelContext, query: SwiftDatabaseQuery<PersistObjectType>?) -> [PersistObjectType] {
        
        let objects: [PersistObjectType]
        
        do {
            objects = try context.fetch(getFetchDescriptor(query: query))
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            objects = Array()
        }
        
        return objects
    }
}

// MARK: - Write

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
}

// MARK: - Delete

@available(iOS 17, *)
extension SwiftRepositorySyncPersistence {
    
    func deleteAllObjects() {
        
        swiftDatabase.deleteAllData()
    }
}
