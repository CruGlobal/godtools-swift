//
//  UserCountersApiInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 4/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

protocol UserCountersApiInterface: ExternalDataFetchInterface {
    
    func fetchUserCounters(requestPriority: RequestPriority) async throws -> [UserCounterDecodable]
    func incrementUserCounter(id: String, increment: Int, requestPriority: RequestPriority) async throws -> UserCounterDecodable
}

extension UserCountersApiInterface {
    
    func getObject(id: String, context: RequestOperationFetchContext) async throws -> [UserCounterDecodable] {
        return Array()
    }
    
    func getObjects(context: RequestOperationFetchContext) async throws -> [UserCounterDecodable] {
        return Array()
    }
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[UserCounterDecodable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[UserCounterDecodable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
