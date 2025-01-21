//
//  RemoteConfigRepository.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//


import Foundation
import Combine

class RemoteConfigRepository {
        
    private let remoteDatabase: RemoteConfigRemoteDatabaseInterface
    
    init(remoteDatabase: RemoteConfigRemoteDatabaseInterface) {
        
        self.remoteDatabase = remoteDatabase
    }
    
    func syncDataPublisher() -> AnyPublisher<Void, Never> {
        
        return remoteDatabase.syncFromRemoteDatabasePublisher()
            .eraseToAnyPublisher()
    }
    
    func getRemoteConfigPublisher() -> AnyPublisher<RemoteConfigDataModel?, Never> {
        
        return remoteDatabase.getRemoteConfigPublisher()
            .eraseToAnyPublisher()
    }
}
