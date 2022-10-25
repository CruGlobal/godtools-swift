//
//  InfoPlist.swift
//  godtools
//
//  Created by Levi Eggert on 9/30/22.
//  Copyright © 2022 Cru. All rights reserved.
//
import Foundation

class InfoPlist {

    let info: [String: Any]

    init() {

        info = Bundle.main.infoDictionary ?? [:]
    }

    var displayName: String? {
        return info["CFBundleDisplayName"] as? String
    }

    var appVersion: String? {
        return info["CFBundleShortVersionString"] as? String
    }

    var bundleIdentifier: String? {
        return info["CFBundleIdentifier"] as? String
    }

    var bundleVersion: String? {
        return info["CFBundleVersion"] as? String
    }

    var configuration: String? {
        return info["Configuration"] as? String
    }
}
