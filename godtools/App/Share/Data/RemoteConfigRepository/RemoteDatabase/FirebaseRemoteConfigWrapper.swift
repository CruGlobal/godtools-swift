//
//  FirebaseRemoteConfigWrapper.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import FirebaseRemoteConfigInternal

class FirebaseRemoteConfigWrapper: RemoteConfigRemoteDatabaseInterface {
    
    private let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    
    init() {
        
    }
    
    func syncFromRemoteDatabasePublisher() -> AnyPublisher<Void, Never> {
        
        // NOTE: By default RemoteConfig fetches new data after 12 hours have elapsed. Can be configured in RemoteConfigSettings. ~Levi
        
        return fetchAndActivatePublisher()
            .catch { _ in
                return Just(RemoteConfigFetchAndActivateStatus.error)
                    .eraseToAnyPublisher()
            }
            .map { _ in
                Void()
            }
            .eraseToAnyPublisher()
    }
    
    func getRemoteConfigPublisher() -> AnyPublisher<RemoteConfigDataModel?, Never> {
        
        return Just(getRemoteConfigDataModel())
            .eraseToAnyPublisher()
    }
    
    private func getRemoteConfigDataModel() -> RemoteConfigDataModel? {
        
        let globalActivityIsEnabledValue: RemoteConfigValue? = remoteConfig.configValue(forKey: "ui_account_globalactivity_enabled")
        
        guard let globalActivityIsEnabled = globalActivityIsEnabledValue?.boolValue else {
            return nil
        }
        
        return RemoteConfigDataModel(globalActivityIsEnabled: globalActivityIsEnabled)
    }
}

extension FirebaseRemoteConfigWrapper {
    
    private func fetchAndActivatePublisher() -> AnyPublisher<RemoteConfigFetchAndActivateStatus, Error> {
        
        return Future() { promise in
            
            self.remoteConfig.fetchAndActivate { (status: RemoteConfigFetchAndActivateStatus, error: Error?) in
                
                if let error = error {
                    promise(.failure(error))
                }
                else {
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
