//
//  NoExternalDataFetch.swift
//  godtools
//
//  Created by Levi Eggert on 2/5/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RepositorySync
import Combine

class NoExternalDataFetch<DataModelType> {
    
    init() {
        
    }
}

extension NoExternalDataFetch: ExternalDataFetchInterface {
    
    func getObject(id: String, context: RequestOperationFetchContext) async throws -> [DataModelType] {
        return try await emptyResponse()
    }
    
    func getObjects(context: RequestOperationFetchContext) async throws -> [DataModelType] {
        return try await emptyResponse()
    }
    
    @available(*, deprecated) func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[DataModelType], Error> {
        return emptyResponsePublisher()
    }
    
    @available(*, deprecated) func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[DataModelType], Error> {
        return emptyResponsePublisher()
    }
}
