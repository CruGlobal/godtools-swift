//
//  RepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class RepositorySync<DataModelType, ExternalDataFetchType: RepositorySyncExternalDataFetchInterface, PersistenceQueryType> {
    
    private let externalDataFetch: ExternalDataFetchType
    
    let persistence: any RepositorySyncPersistence<DataModelType, PersistenceQueryType, ExternalDataFetchType.DataModel>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, persistence: any RepositorySyncPersistence<DataModelType, PersistenceQueryType, ExternalDataFetchType.DataModel>) {
        
        self.externalDataFetch = externalDataFetch
        self.persistence = persistence
    }
}

// MARK: - External Data Fetch

extension RepositorySync {
    
    private func fetchExternalObjects(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<ExternalDataFetchType.DataModel>, Never>  {
        
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
    
    private func makeSinkingfetchAndStoreObjectsFromExternalDataFetch(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>, requestPriority: RequestPriority) {
        
        fetchAndStoreObjectsFromExternalDataFetchPublisher(
            getObjectsType: getObjectsType,
            requestPriority: requestPriority
        )
        .sink { (response: RepositorySyncResponse<DataModelType>) in
            
        }
        .store(in: &cancellables)
    }
    
    private func fetchAndStoreObjectsFromExternalDataFetchPublisher(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>, requestPriority: RequestPriority) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
        return fetchExternalObjects(getObjectsType: getObjectsType, requestPriority: requestPriority)
            .map { (getObjectsResponse: RepositorySyncResponse<ExternalDataFetchType.DataModel>) in
                return self.storeExternalObjectsToPersistence(
                    externalObjects: getObjectsResponse.objects
                )
            }
            .eraseToAnyPublisher()
    }
    
    public func storeExternalObjectsToPersistence(externalObjects: [ExternalDataFetchType.DataModel]) -> RepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = persistence.writeObjects(
            externalObjects: externalObjects,
            deleteObjectsNotFoundInExternalObjects: false
        )
        
        return RepositorySyncResponse<DataModelType>(objects: dataModels, errors: [])
    }
}

// MARK: - Get Objects

extension RepositorySync {
    
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
        - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
     */
    
    public func getObjectsPublisher(getObjectsType: RepositorySyncGetObjectsType<PersistenceQueryType>, cachePolicy: RepositorySyncCachePolicy) -> AnyPublisher<RepositorySyncResponse<DataModelType>, Never> {
                
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
            
            if observeChanges {

                if persistence.getObjectCount() == 0 {

                    makeSinkingfetchAndStoreObjectsFromExternalDataFetch(
                        getObjectsType: getObjectsType,
                        requestPriority: requestPriority
                    )
                }

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

                if persistence.getObjectCount() == 0 {

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

            return persistence
                .observeCollectionChangesPublisher()
                .map { (onChange: Void) in

                    return self.getCachedDataModelsByGetObjectsTypeToResponse(
                        getObjectsType: getObjectsType
                    )
                }
                .eraseToAnyPublisher()
        }
    }
}
