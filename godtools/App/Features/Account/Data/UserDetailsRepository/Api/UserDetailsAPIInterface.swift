//
//  UserDetailsAPIInterface.swift
//  godtools
//
//  Created by Rachael Skeath on 8/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

protocol UserDetailsAPIInterface: ExternalDataFetchInterface {
    
    func fetchUserDetails(requestPriority: RequestPriority) async throws -> MobileContentApiUsersMeCodable
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws
}

extension UserDetailsAPIInterface {
    
    func getObject(id: String, context: RequestOperationFetchContext) async throws -> [MobileContentApiUsersMeCodable] {
        return Array()
    }
    
    func getObjects(context: RequestOperationFetchContext) async throws -> [MobileContentApiUsersMeCodable] {
        return Array()
    }
    
    func getObjectPublisher(id: String, context: RequestOperationFetchContext) -> AnyPublisher<[MobileContentApiUsersMeCodable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func getObjectsPublisher(context: RequestOperationFetchContext) -> AnyPublisher<[MobileContentApiUsersMeCodable], Error> {
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
