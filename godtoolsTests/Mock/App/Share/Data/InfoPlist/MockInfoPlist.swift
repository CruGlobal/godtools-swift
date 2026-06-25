//
//  MockInfoPlist.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 6/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockInfoPlist: InfoPlistInterface {

    let displayName: String?
    let appVersion: String?
    let bundleIdentifier: String?
    let bundleVersion: String?
    let configuration: String?

    private let appBuildConfiguration: AppBuildConfiguration?

    init(displayName: String? = nil, appVersion: String? = nil, bundleIdentifier: String? = nil, bundleVersion: String? = nil, configuration: String? = nil, appBuildConfiguration: AppBuildConfiguration? = nil) {

        self.displayName = displayName
        self.appVersion = appVersion
        self.bundleIdentifier = bundleIdentifier
        self.bundleVersion = bundleVersion
        self.configuration = configuration
        self.appBuildConfiguration = appBuildConfiguration
    }

    func getAppBuildConfiguration() -> AppBuildConfiguration? {
        return appBuildConfiguration
    }
}
