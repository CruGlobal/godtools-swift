//
//  RemoteConfigRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation

final class RemoteConfigRepository: Sendable {
        
    private let remoteDatabase: RemoteConfigRemoteDatabaseInterface
    
    init(remoteDatabase: RemoteConfigRemoteDatabaseInterface) {
        
        self.remoteDatabase = remoteDatabase
    }
    
    func syncData() async throws {
        
        try await remoteDatabase.syncFromRemoteDatabase()
    }

    func getRemoteConfig() async -> RemoteConfigDataModel? {
        
        return await remoteDatabase.getRemoteConfig()
    }
}
