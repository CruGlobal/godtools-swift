//
//  DeviceLanguageType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol DeviceLanguageType {
    
    var locale: Locale { get }
    var languageCode: String? { get }
    var preferredLocalizationLocale: Locale? { get }
    var preferredLocalizationLocaleIdentifier: String? { get }
    var isEnglish: Bool { get }
    
    func possibleLocaleCodes(locale: Locale) -> [String]
}
