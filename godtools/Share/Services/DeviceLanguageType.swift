//
//  DeviceLanguageType.swift
//  godtools
//
//  Created by Levi Eggert on 3/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol DeviceLanguageType {
    
    var languageCode: String? { get }
    var isEnglish: Bool { get }
    
    func possibleLocaleCodes(locale: Locale) -> [String]
}
