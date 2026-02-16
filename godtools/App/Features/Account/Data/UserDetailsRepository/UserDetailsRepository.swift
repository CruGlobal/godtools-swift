//
//  UserDetailsRepository.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine
import RequestOperation
import RepositorySync

class UserDetailsRepository: RepositorySync<UserDetailsDataModel, UserDetailsAPI> {
    
    private let api: UserDetailsAPI
    private let cache: UserDetailsCache
    
    init(externalDataFetch: UserDetailsAPI, persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>, cache: UserDetailsCache) {
        
        self.api = externalDataFetch
        self.cache = cache
        
        super.init(externalDataFetch: externalDataFetch, persistence: persistence)
    }
    
    @MainActor func getAuthUserDetailsChangedPublisher() -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        return persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                let userDetails: UserDetailsDataModel? = try self.cache.getAuthUserDetails()
                return userDetails
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func getUserDetailsChangedPublisher(id: String) -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        return persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                let userDetails: UserDetailsDataModel? = try self.persistence.getDataModel(id: id)
                return userDetails
            }
            .eraseToAnyPublisher()
    }
    
    func getCachedAuthUserDetails() throws -> UserDetailsDataModel? {
        
        return try cache.getAuthUserDetails()
    }
    
    func getAuthUserDetailsFromRemote(requestPriority: RequestPriority) async throws -> UserDetailsDataModel {
        
        let codable: MobileContentApiUsersMeCodable = try await api.fetchUserDetails(requestPriority: requestPriority)
        
        _ = try await persistence.writeObjectsAsync(
            externalObjects: [codable],
            writeOption: nil,
            getOption: nil
        )
        
        return UserDetailsDataModel(interface: codable)
    }
    
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws {
        
        try await api.deleteAuthUserDetails(requestPriority: requestPriority)
    }
}
