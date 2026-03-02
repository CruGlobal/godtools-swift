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
    
    private var cancellables: Set<AnyCancellable> = Set()
        
    init(externalDataFetch: UserDetailsAPI, persistence: any Persistence<UserDetailsDataModel, MobileContentApiUsersMeCodable>, cache: UserDetailsCache) {
        
        self.api = externalDataFetch
        self.cache = cache
        
        super.init(externalDataFetch: externalDataFetch, persistence: persistence)
    }
    
    @MainActor func getAuthUserDetailsChangedPublisher(requestPriority: RequestPriority) -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        makeSinkWithRemote(requestPriority: requestPriority)
        
        return persistence
            .observeCollectionChangesPublisher()
            .tryMap { _ in
                let userDetails: UserDetailsDataModel? = try self.cache.getAuthUserDetails()
                return userDetails
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor func getUserDetailsChangedPublisher(id: String, requestPriority: RequestPriority) -> AnyPublisher<UserDetailsDataModel?, Error> {
        
        makeSinkWithRemote(requestPriority: requestPriority)
        
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
    
    func deleteAuthUserDetails(requestPriority: RequestPriority) async throws {
        
        try await api.deleteAuthUserDetails(requestPriority: requestPriority)
    }
}

extension UserDetailsRepository {
    
    private func makeSinkWithRemote(requestPriority: RequestPriority) {
        
        syncFromRemotePublisher(
            requestPriority: requestPriority
        )
        .sink { _ in
            
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)
    }
    
    private func syncFromRemotePublisher(requestPriority: RequestPriority) -> AnyPublisher<UserDetailsDataModel, Error> {
        return AnyPublisher() {
            return try await self.syncFromRemote(requestPriority: requestPriority)
        }
    }
    
    private func syncFromRemote(requestPriority: RequestPriority) async throws -> UserDetailsDataModel {
        
        let codable: MobileContentApiUsersMeCodable = try await api.fetchUserDetails(requestPriority: requestPriority)
        
        _ = try await persistence.writeObjectsAsync(
            externalObjects: [codable],
            writeOption: nil,
            getOption: nil
        )
        
        return UserDetailsDataModel(interface: codable)
    }
}
