//
//  LocalizationServicesDefaults.swift
//  godtools
//
//  Created by Levi Eggert on 8/17/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

enum LocalizationServicesDefaults {

    static var fallbackToKey: Bool {
        return true
    }

    static func getFetchOrder(localeIdentifier: String) -> [StringLocation] {
        return [.locale(identifier: localeIdentifier), .english]
    }
}
