//
//  FirebaseRemoteConfigWrapper.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

final class FirebaseRemoteConfigWrapper: RemoteConfigRemoteDatabaseInterface {
    
    private let remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()
    
    init() {
        
    }
    
    func syncFromRemoteDatabase() async throws {
        
        // NOTE: By default RemoteConfig fetches new data after 12 hours have elapsed. Can be configured in RemoteConfigSettings. ~Levi
        
        _ = try await fetchAndActivate()
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
    
    private func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus {
        
        return try await remoteConfig.fetchAndActivate()
    }
}
