//
//  FirebaseRemoteConfigWrapper.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import Combine
import FirebaseRemoteConfig

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
    
    func getRemoteConfig() -> RemoteConfigDataModel? {
        return getRemoteConfigDataModel()
    }
    
    private func getRemoteConfigDataModel() -> RemoteConfigDataModel? {
        
        return RemoteConfigDataModel(
            globalActivityIsEnabled: remoteConfig.configValue(forKey: "ui_account_globalactivity_enabled").boolValue,
            toolContentFeaturePageCollectionPageEnabled: remoteConfig.configValue(forKey: "tool_content_feature_page_collection_page_enabled").boolValue,
            optInNotificationEnabled: remoteConfig.configValue(forKey: "ui_opt_in_notification_enabled").boolValue,
            optInNotificationPromptLimit: Int(truncating: remoteConfig.configValue(forKey: "ui_opt_in_notification_prompt_limit").numberValue),
            optInNotificationTimeInterval: Int(truncating: remoteConfig.configValue(forKey: "ui_opt_in_notification_time_interval").numberValue)
        )
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
