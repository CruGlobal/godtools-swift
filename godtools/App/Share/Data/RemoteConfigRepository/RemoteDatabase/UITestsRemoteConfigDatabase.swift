//
//  UITestsRemoteConfigDatabase.swift
//  godtools
//
//  Created by Jason Bennett on 11/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

actor UITestsRemoteConfigDatabase: RemoteConfigRemoteDatabaseInterface {

    init() {

    }

    func syncFromRemoteDatabase() async throws {

    }

    func getRemoteConfig() -> RemoteConfigDataModel? {

        return RemoteConfigDataModel(
            globalActivityIsEnabled: nil,
            toolContentFeaturePageCollectionPageEnabled: nil,
            optInNotificationEnabled: nil,
            optInNotificationPromptLimit: nil,
            optInNotificationTimeInterval: nil,
            personalizationIsEnabled: true
        )
    }
}
