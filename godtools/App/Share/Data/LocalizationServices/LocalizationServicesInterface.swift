//
//  LocalizationServicesInterface.swift
//  godtools
//
//  Created by Levi Eggert on 10/16/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import LocalizationServices

protocol LocalizationServicesInterface: Sendable {
    
    func stringsForKeys(
        keys: [String],
        fetchOrder: [StringLocation],
        shouldFallbackToKey: Bool
    ) -> [String: String]
    
    func stringForEnglishElseKey(key: String) -> String
    func stringForLocale(localeIdentifier: String, key: String) -> String?
}
