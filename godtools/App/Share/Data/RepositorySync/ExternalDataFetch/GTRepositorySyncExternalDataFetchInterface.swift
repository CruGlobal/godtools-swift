//
//  GTRepositorySyncExternalDataFetchInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/30/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation

public protocol GTRepositorySyncExternalDataFetchInterface {
    
    associatedtype DataModel
    
    func getObjectPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<DataModel>, Never>
    func getObjectsPublisher(requestPriority: RequestPriority) -> AnyPublisher<GTRepositorySyncResponse<DataModel>, Never>
}

extension GTRepositorySyncExternalDataFetchInterface {
    
    func emptyResponsePublisher() -> AnyPublisher<GTRepositorySyncResponse<DataModel>, Never> {
        
        let emptyResponse = GTRepositorySyncResponse<DataModel>(
            objects: [],
            errors: []
        )
        
        return Just(emptyResponse)
            .eraseToAnyPublisher()
    }
}
