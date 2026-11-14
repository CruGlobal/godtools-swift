//
//  FakeRemoteConfigRemoteDatabase.swift
//  godtoolsTests
//
//  Created by Jason Bennett on 11/6/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

actor FakeRemoteConfigRemoteDatabase: RemoteConfigRemoteDatabaseInterface {

    private let remoteConfig: RemoteConfigDataModel?

    init(remoteConfig: RemoteConfigDataModel?) {

        self.remoteConfig = remoteConfig
    }

    func syncFromRemoteDatabase() async throws {

    }

    func getRemoteConfig() -> RemoteConfigDataModel? {
        return remoteConfig
    }
}
