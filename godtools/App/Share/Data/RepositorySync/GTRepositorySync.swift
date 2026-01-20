//
//  GTRepositorySync.swift
//  godtools
//
//  Created by Levi Eggert on 9/23/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

class GTRepositorySync<DataModelType, ExternalDataFetchType: GTRepositorySyncExternalDataFetchInterface> {
    
    private let externalDataFetch: ExternalDataFetchType
    
    let persistence: any GTRepositorySyncPersistence<DataModelType, ExternalDataFetchType.DataModel>
    
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(externalDataFetch: ExternalDataFetchType, persistence: any GTRepositorySyncPersistence<DataModelType, ExternalDataFetchType.DataModel>) {
        
        self.externalDataFetch = externalDataFetch
        self.persistence = persistence
    }
}

// MARK: - External Data Fetch

extension GTRepositorySync {
    
    private func fetchExternalObjects(getObjectsType: GTRepositorySyncGetObjectsType, requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<ExternalDataFetchType.DataModel>, Never>  {
        
        switch getObjectsType {
        case .allObjects:
            return externalDataFetch
                .getObjectsPublisher(requestPriority: requestPriority)
                .eraseToAnyPublisher()
            
        case .object(let id):
            return externalDataFetch
                .getObjectPublisher(id: id, requestPriority: requestPriority)
                .eraseToAnyPublisher()
        }
    }
    
    private func makeSinkingfetchAndStoreObjectsFromExternalDataFetch(getObjectsType: GTRepositorySyncGetObjectsType, requestPriority: RequestPriority) {
        
        fetchAndStoreObjectsFromExternalDataFetchPublisher(
            getObjectsType: getObjectsType,
            requestPriority: requestPriority
        )
        .sink { (response: GTRepositorySyncResponse<DataModelType>) in
            
        }
        .store(in: &cancellables)
    }
    
    private func fetchAndStoreObjectsFromExternalDataFetchPublisher(getObjectsType: GTRepositorySyncGetObjectsType, requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<DataModelType>, Never> {
                
        return fetchExternalObjects(getObjectsType: getObjectsType, requestPriority: requestPriority)
            .map { (getObjectsResponse: GTRepositorySyncResponse<ExternalDataFetchType.DataModel>) in
                return self.storeExternalObjectsToPersistence(
                    externalObjects: getObjectsResponse.objects
                )
            }
            .eraseToAnyPublisher()
    }
    
    public func storeExternalObjectsToPersistence(externalObjects: [ExternalDataFetchType.DataModel], deleteObjectsNotFoundInExternalObjects: Bool = false) -> GTRepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = persistence.writeObjects(
            externalObjects: externalObjects,
            deleteObjectsNotFoundInExternalObjects: deleteObjectsNotFoundInExternalObjects
        )
        
        return GTRepositorySyncResponse<DataModelType>(objects: dataModels, errors: [])
    }
}

// MARK: - Get Objects

extension GTRepositorySync {
    
    private func getCachedDataModelsByGetObjectsType(getObjectsType: GTRepositorySyncGetObjectsType) -> [DataModelType] {
        
        let dataModels: [DataModelType]
        
        switch getObjectsType {
        
        case .allObjects:
            dataModels = persistence.getObjects()
            
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
    
    private func getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: GTRepositorySyncGetObjectsType) -> GTRepositorySyncResponse<DataModelType> {
        
        let dataModels: [DataModelType] = getCachedDataModelsByGetObjectsType(
            getObjectsType: getObjectsType
        )
        
        let response = GTRepositorySyncResponse<DataModelType>(
            objects: dataModels,
            errors: []
        )
        
        return response
    }
    
    private func getCachedDataModelsByGetObjectsTypeToResponsePublisher(getObjectsType: GTRepositorySyncGetObjectsType) -> AnyPublisher<GTRepositorySyncResponse<DataModelType>, Never> {
        
        return Just(getCachedDataModelsByGetObjectsTypeToResponse(getObjectsType: getObjectsType))
            .eraseToAnyPublisher()
    }
    
    // TODO: Questions, Unknowns, Etc.
    /*
        - How do we handle more complex external data fetching?  For instance, a url request could contain query parameters and http body. Do we force that on subclasses of repository sync?  Do we provide methods for subclasses to hook into for observing, pushing data models for syncing, etc?
     */
    
    public func getObjectsPublisher(getObjectsType: GTRepositorySyncGetObjectsType, cachePolicy: GTRepositorySyncCachePolicy) -> AnyPublisher<GTRepositorySyncResponse<DataModelType>, Never> {
                
        switch cachePolicy {
            
        case .fetchIgnoringCacheData(let requestPriority):
            
            return fetchAndStoreObjectsFromExternalDataFetchPublisher(
                getObjectsType: getObjectsType,
                requestPriority: requestPriority
            )
            .map { (response: GTRepositorySyncResponse<DataModelType>) in

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
                    .map { (response: GTRepositorySyncResponse<DataModelType>) in

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
