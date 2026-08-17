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
    func stringForLocaleElseEnglishElseKey(localeIdentifier: String, key: String) -> String
}

extension LocalizationServices: LocalizationServicesInterface {

    static var defaultFallbackToKey: Bool {
        return true
    }
    
    static func getDefaultFetchOrder(localeIdentifier: String) -> [StringLocation] {
        return [.locale(identifier: localeIdentifier), .english]
    }
}
