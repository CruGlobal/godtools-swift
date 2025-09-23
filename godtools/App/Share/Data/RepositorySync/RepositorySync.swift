//
//  RepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine

class RepositorySync<DataModelType, PersistenceQueryType> {
    
    let persistence: any RepositorySyncPersistence<DataModelType, PersistenceQueryType>
    
    init(persistence: any RepositorySyncPersistence<DataModelType, PersistenceQueryType>) {
        
        self.persistence = persistence
    }
    
    private func getCachedDataModelsByGetObjectsType(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>) -> [DataModelType] {
        
        let dataModels: [DataModelType]
        
        switch getObjectsType {
        
        case .allObjects:
            dataModels = persistence.getObjects(query: nil)
        
        case .objectsWithQuery(let query):
            dataModels = persistence.getObjects(query: query)
            
        case .object(let id):
            if let dataModel = persistence.getObject(id: id) {
                dataModels = [dataModel]
            }
            else {
                dataModels = []
            }
        }
        
        return dataModels
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>) -> RepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = getCachedDataModelsByGetObjectsType(
            getObjectsType: getObjectsType
        )
        
        let response = RepositorySyncResponse<DataModelType>(
            objects: dataModels,
            errors: []
        )
        
        return response
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponsePublisher(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
        
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
    
    public func getObjectsPublisher(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>, cachePolicy: RepositorySyncCachePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        switch cachePolicy {
            
        case .fetchIgnoringCacheData(let requestPriority):
            return Just(RepositorySyncResponse(objects: [], errors: [])).eraseToAnyPublisher() // TODO: Implmement. ~Levi
            
//            return fetchAndStoreObjectsFromExternalDataFetchPublisher(
//                getObjectsType: getObjectsType,
//                requestPriority: requestPriority
//            )
//            .map { (response: RepositorySyncResponse<DataModelType>) in
//            
//                let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
//                    getObjectsType: getObjectsType
//                )
//                
//                return response.copy(objects: dataModels)
//            }
//            .eraseToAnyPublisher()
            
        case .returnCacheDataDontFetch(let observeChanges):
            
            if observeChanges {
               
                return persistence
                    .observeCollectionChangesPublisher()
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
            return Just(RepositorySyncResponse(objects: [], errors: [])).eraseToAnyPublisher() // TODO: Implmement. ~Levi
            
//            if observeChanges {
//                        
//                let numberOfCachedObjects: Int = getNumberOfCachedObjects()
//                
//                if numberOfCachedObjects == 0 {
//                    
//                    makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
//                        getObjectsType: getObjectsType,
//                        requestPriority: requestPriority
//                    )
//                }
//                
//                return observeSwiftDataCollectionChangesPublisher()
//                .map { (onChange: Void) in
//                    
//                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
//                        getObjectsType: getObjectsType
//                    )
//                }
//                .eraseToAnyPublisher()
//            }
//            else {
//                
//                if getNumberOfCachedObjects() == 0 {
//                    
//                    return fetchAndStoreObjectsFromExternalDataFetchPublisher(
//                        getObjectsType: getObjectsType,
//                        requestPriority: requestPriority
//                    )
//                    .map { (response: RepositorySyncResponse<DataModelType>) in
//                    
//                        let dataModels: [DataModelType] = self.getCachedDataModelsByGetObjectsType(
//                            getObjectsType: getObjectsType
//                        )
//                        
//                        return response.copy(objects: dataModels)
//                    }
//                    .eraseToAnyPublisher()
//                }
//                else {
//                    
//                    return getCachedDataModelsByGetObjectsTypeToResponsePublisher(
//                        getObjectsType: getObjectsType
//                    )
//                    .eraseToAnyPublisher()
//                }
//            }
        
        case .returnCacheDataAndFetch(let requestPriority):
            return Just(RepositorySyncResponse(objects: [], errors: [])).eraseToAnyPublisher() // TODO: Implmement. ~Levi
            
//            makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
//                getObjectsType: getObjectsType,
//                requestPriority: requestPriority
//            )
//            
//            return observeSwiftDataCollectionChangesPublisher()
//            .map { (onChange: Void) in
//                
//                return self.getCachedDataModelsByGetObjectsTypeToResponse(
//                    getObjectsType: getObjectsType
//                )
//            }
//            .eraseToAnyPublisher()
        }
    }
}
