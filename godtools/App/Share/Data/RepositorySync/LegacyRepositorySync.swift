//
//  LegacyRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//
/*
import Foundation
import Combine
import RequestOperation
import SwiftData

@available(iOS 17, *)
open class LegacyRepositorySync<DataModelType, ExternalDataFetchType: RepositorySyncExternalDataFetchInterface, SwiftDataObjectType: IdentifiableSwiftDataObject> {
          
    private let externalDataFetch: ExternalDataFetchType
    private let swiftDatabase: SwiftDatabase
    private let dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, SwiftDataObjectType>
    private let userInfoKeyPrependNotification: String = "RepositorySync.notificationKey.prepend"
    private let userInfoKeyEntityName: String = "RepositorySync.notificationKey.entityName"
    private let entityName: String
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, swiftDatabase: SwiftDatabase, dataModelMapping: RepositorySyncMapping<DataModelType, ExternalDataFetchType.DataModel, SwiftDataObjectType>) {
        
        self.externalDataFetch = externalDataFetch
        self.swiftDatabase = swiftDatabase
        self.dataModelMapping = dataModelMapping
        
        if #available(iOS 18.0, *) {
            entityName = Schema.entityName(for: SwiftDataObjectType.self)
        }
        else {
            // TODO: Can remove once supporting iOS 18 and up. ~Levi
            entityName = SwiftDataObjectType.entityName
        }
    }
    
    public var numberOfCachedObjects: Int {
        return getNumberOfCachedObjects()
    }
    
    public func observeCollectionChangesPublisher() -> AnyPublisher<Void, Never> {
        return observeSwiftDataCollectionChangesPublisher()
            .eraseToAnyPublisher()
    }
    
    public func getCachedObject(id: String) -> DataModelType? {
        return getCachedObjectToDataModel(primaryKey: id)
    }
    
    public func getCachedObjects(ids: [String]) -> [DataModelType] {
        
        let filter = #Predicate<SwiftDataObjectType> { object in
            ids.contains(object.id)
        }
        
        return getCachedObjects(
            databaseQuery: SwiftDatabaseQuery.filter(filter: filter)
        )
    }
    
    public func getCachedObjects(databaseQuery: SwiftDatabaseQuery<SwiftDataObjectType>? = nil) -> [DataModelType] {
        return getCachedObjectsToDataModels(databaseQuery: databaseQuery)
    }
}

// MARK: - Cache

@available(iOS 17, *)
extension LegacyRepositorySync {
    
    private func getFetchDescriptor(databaseQuery: SwiftDatabaseQuery<SwiftDataObjectType>?) -> FetchDescriptor<SwiftDataObjectType> {
        return databaseQuery?.fetchDescriptor ?? FetchDescriptor<SwiftDataObjectType>()
    }
    
    private func getNumberOfCachedObjects(databaseQuery: SwiftDatabaseQuery<SwiftDataObjectType>? = nil) -> Int {
       
        do {
            return try swiftDatabase
                .openContext()
                .fetchCount(
                    getFetchDescriptor(databaseQuery: databaseQuery)
                )
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            return 0
        }
    }
    
    private func getCachedSwiftDataObjects(context: ModelContext, databaseQuery: SwiftDatabaseQuery<SwiftDataObjectType>?) -> [SwiftDataObjectType] {
        
        let objects: [SwiftDataObjectType]
        
        do {
            objects = try context.fetch(getFetchDescriptor(databaseQuery: databaseQuery))
        }
        catch let error {
            assertionFailure(error.localizedDescription)
            objects = Array()
        }
        
        return objects
    }
    
    private func getCachedObjectsToDataModels(databaseQuery: SwiftDatabaseQuery<SwiftDataObjectType>?) -> [DataModelType] {
        
        let objects: [SwiftDataObjectType] = getCachedSwiftDataObjects(
            context: swiftDatabase.openContext(),
            databaseQuery: databaseQuery
        )
        
        let dataModels: [DataModelType] = objects.compactMap { object in
            self.dataModelMapping.toDataModel(persistObject: object)
        }
        
        return dataModels
    }
    
    private func getCachedObjectToDataModel(primaryKey: String) -> DataModelType? {
        
        let idPredicate = #Predicate<SwiftDataObjectType> { object in
            object.id == primaryKey
        }
        
        return getCachedObjectsToDataModels(
            databaseQuery: SwiftDatabaseQuery.filter(filter: idPredicate)
        )
        .first
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

// MARK: - External Data Fetch

@available(iOS 17, *)
extension LegacyRepositorySync {
    
    private func fetchExternalObjects(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<ExternalDataFetchType.DataModel>, Never>  {
        
        switch getObjectsType {
        case .allObjects:
            return externalDataFetch
                .getObjectsPublisher(requestPriority: requestPriority)
                .eraseToAnyPublisher()
            
        case .objectsWithQuery( _):
            return externalDataFetch
                .getObjectsPublisher(requestPriority: requestPriority)
                .eraseToAnyPublisher()
            
        case .object(let id):
            return externalDataFetch
                .getObjectPublisher(id: id, requestPriority: requestPriority)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeSinkingfetchAndStoreObjectsFromExternalDataFetch(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>, requestPriority: RequestPriority) {
        
        fetchAndStoreObjectsFromExternalDataFetchPublisher(
            getObjectsType: getObjectsType,
            requestPriority: requestPriority
        )
        .sink { (response: RepositorySyncResponse<DataModelType>) in
            
        }
        .store(in: &cancellables)
    }
    
    private func fetchAndStoreObjectsFromExternalDataFetchPublisher(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return fetchExternalObjects(getObjectsType: getObjectsType, requestPriority: requestPriority)
            .map { (getObjectsResponse: RepositorySyncResponse<ExternalDataFetchType.DataModel>) in
                return self.storeExternalDataFetchResponse(
                    response: getObjectsResponse
                )
            }
            .eraseToAnyPublisher()
    }
    
    public func storeExternalDataFetchResponse(response: RepositorySyncResponse<ExternalDataFetchType.DataModel>) -> RepositorySyncResponse<DataModelType> {
        
        let context: ModelContext = swiftDatabase.openContext()
        
        let objectsToAdd: [SwiftDataObjectType] = response.objects.compactMap {
            self.dataModelMapping.toPersistObject(externalObject: $0)
        }
        
        updateObjectsInSwiftDatabase(
            context: context,
            objectsToAdd: objectsToAdd,
            objectsToRemove: []
        )
        
        return RepositorySyncResponse<DataModelType>(
            objects: response.objects.compactMap { self.dataModelMapping.toDataModel(externalObject: $0) },
            errors: []
        )
    }
    
    public func syncExternalDataFetchResponse(response: RepositorySyncResponse<ExternalDataFetchType.DataModel>) -> RepositorySyncResponse<DataModelType> {

        let shouldDeleteObjectsNotFoundInResponse: Bool = true
        
        let context: ModelContext = swiftDatabase.openContext()
        
        var responseDataModels: [DataModelType] = Array()
        
        var objectsToAdd: [any PersistentModel] = Array()
        // store all objects in the collection
        var objectsToRemove: [SwiftDataObjectType] = getCachedSwiftDataObjects(context: context, databaseQuery: nil)
        
        for externalObject in response.objects {

            if let dataModel = dataModelMapping.toDataModel(externalObject: externalObject) {
                responseDataModels.append(dataModel)
            }
            
            if let swiftDataObject = dataModelMapping.toPersistObject(externalObject: externalObject) {
                
                objectsToAdd.append(swiftDataObject)
                
                // added swift data object can be removed from this list so it won't be deleted from swift data
                if shouldDeleteObjectsNotFoundInResponse, let index = objectsToRemove.firstIndex(where: { $0.id == swiftDataObject.id }) {
                    objectsToRemove.remove(at: index)
                }
            }
        }
        
        updateObjectsInSwiftDatabase(
            context: context,
            objectsToAdd: objectsToAdd,
            objectsToRemove: objectsToRemove
        )

        return RepositorySyncResponse<DataModelType>(
            objects: responseDataModels,
            errors: []
        )
    }
    
    private func updateObjectsInSwiftDatabase(context: ModelContext, objectsToAdd: [any PersistentModel], objectsToRemove: [any PersistentModel]) {
        
        for object in objectsToAdd {
            context.insert(object)
        }
        
        for object in objectsToRemove {
            context.delete(object)
        }
        
        guard context.hasChanges else {
            return
        }
                
        do {
            try context.save()
        }
        catch let error {
            assertionFailure("Failed to save SwiftData context with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Get Objects

@available(iOS 17, *)
extension LegacyRepositorySync {
    
    private func getCachedDataModelsByGetObjectsType(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>) -> [DataModelType] {
        
        let dataModels: [DataModelType]
        
        switch getObjectsType {
        
        case .allObjects:
            dataModels = getCachedObjectsToDataModels(databaseQuery: nil)
        
        case .objectsWithQuery(let databaseQuery):
            dataModels = getCachedObjectsToDataModels(databaseQuery: databaseQuery)
            
        case .object(let id):
            if let dataModel = getCachedObjectToDataModel(primaryKey: id) {
                dataModels = [dataModel]
            }
            else {
                dataModels = []
            }
        }
        
        return dataModels
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>) -> RepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = getCachedDataModelsByGetObjectsType(
            getObjectsType: getObjectsType
        )
        
        let response = RepositorySyncResponse<DataModelType>(
            objects: dataModels,
            errors: []
        )
        
        return response
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponsePublisher(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
        return Just(getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: getObjectsType))
            .eraseToAnyPublisher()
    }
    
    // TODO: Questions, Unknowns, Etc.
    /*
        - Is there a better way to setup RepositorySyncMapping?  I couldn't get it to work with a protocol and associated types. Not sure I like the open class because there isn't an explicit way to force subclasses to override parent methods.
        - Can we observe a specific realm object and only trigger when there are actual changes? (https://www.mongodb.com/docs/atlas/device-sdks/sdk/swift/react-to-changes/)
        - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
        -
     */
    
    public func getObjectsPublisher(getObjectsType: RepositorySyncGetObjectsType<SwiftDataObjectType>, cachePolicy: RepositorySyncCachePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        switch cachePolicy {
            
        case .fetchIgnoringCacheData(let requestPriority):
            
            return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                getObjectsType: getObjectsType,
                requestPriority: requestPriority
            )
            .map { (response: RepositorySyncResponse<DataModelType>) in
            
                let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
                    getObjectsType: getObjectsType
                )
                
                return response.copy(objects: dataModels)
            }
            .eraseToAnyPublisher()
            
        case .returnCacheDataDontFetch(let observeChanges):
            
            if observeChanges {
               
                return observeSwiftDataCollectionChangesPublisher()
                .map { (onChange: Void) in
                    
                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
                        getObjectsType: getObjectsType
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
               
                return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                    getObjectsType: getObjectsType
                )
                .eraseToAnyPublisher()
            }
        
        case .returnCacheDataElseFetch(let requestPriority, let observeChanges):
            
            if observeChanges {
                        
                let numberOfCachedObjects: Int = getNumberOfCachedObjects()
                
                if numberOfCachedObjects == 0 {
                    
                    makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority
                    )
                }
                
                return observeSwiftDataCollectionChangesPublisher()
                .map { (onChange: Void) in
                    
                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
                        getObjectsType: getObjectsType
                    )
                }
                .eraseToAnyPublisher()
            }
            else {
                
                if getNumberOfCachedObjects() == 0 {
                    
                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority
                    )
                    .map { (response: RepositorySyncResponse<DataModelType>) in
                    
                        let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
                            getObjectsType: getObjectsType
                        )
                        
                        return response.copy(objects: dataModels)
                    }
                    .eraseToAnyPublisher()
                }
                else {
                    
                    return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
                        getObjectsType: getObjectsType
                    )
                    .eraseToAnyPublisher()
                }
            }
        
        case .returnCacheDataAndFetch(let requestPriority):
            
            makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                getObjectsType: getObjectsType,
                requestPriority: requestPriority
            )
            
            return observeSwiftDataCollectionChangesPublisher()
            .map { (onChange: Void) in
                
                return self.getCachedDataModelsByGetObjectsTypeToResponse(
                    getObjectsType: getObjectsType
                )
            }
            .eraseToAnyPublisher()
        }
    }
}
*/
