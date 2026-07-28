//
//  InfoPlistInterface.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol InfoPlistInterface: Sendable {

    var displayName: String? { get }
    var appVersion: String? { get }
    var bundleIdentifier: String? { get }
    var bundleVersion: String? { get }
    var configuration: String? { get }

    func getAppBuildConfiguration() -> AppBuildConfiguration?
}
