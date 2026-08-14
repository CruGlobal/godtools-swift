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

final class UserDetailsRepository: Sendable {
    
    private let api: UserDetailsApiInterface
    private let cache: UserDetailsCache
    private let authTokenRepository: MobileContentAuthTokenRepository
    
    private var syncWithRemoteTask: Task<Void, Error>?
        
    init(api: UserDetailsApiInterface, cache: UserDetailsCache, authTokenRepository: MobileContentAuthTokenRepository) {
        
        self.api = api
        self.cache = cache
        self.authTokenRepository = authTokenRepository
    }
    
    deinit {
        syncWithRemoteTask?.cancel()
    }
    
    @MainActor func getAuthUserDetailsChangedPublisher(requestPriority: RequestPriority) -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        syncWithRemote(requestPriority: requestPriority)
        
        return cache.persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                let userDetails: UserDetailsDataModel? = try self.getAuthUserDetails()
                return userDetails
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func getUserDetailsChangedPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        syncWithRemote(requestPriority: requestPriority)
        
        return cache.persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                let userDetails: UserDetailsDataModel? = try self.cache.persistence.getDataModel(id: id)
                return userDetails
            }
            .eraseToAnyPublisher()
    }
    
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws {
        
        try await api.deleteAuthUserDetails(requestPriority: requestPriority)
    }
    
    func getAuthUserDetails() throws -> UserDetailsDataModel? {
        
        guard let userId = authTokenRepository.getUserId() else {
            return nil
        }
        
        return try cache.persistence
            .getDataModel(id: userId)
    }
}

extension UserDetailsRepository {
    
    private func syncWithRemote(requestPriority: RequestPriority) {
        
        syncWithRemoteTask?.cancel()
        
        syncWithRemoteTask = Task {
            _ = try await syncFromRemote(requestPriority: requestPriority)
        }
    }
    
    private func syncFromRemote(requestPriority: RequestPriority) async throws -> UserDetailsDataModel {
        
        let codable: MobileContentApiUsersMeCodable = try await api.fetchUserDetails(requestPriority: requestPriority)
        
        _ = try await cache.persistence.writeObjects(
            externalObjects: [codable],
            writeOption: nil,
            getOption: nil
        )
        
        return codable.toModel()
    }
}
