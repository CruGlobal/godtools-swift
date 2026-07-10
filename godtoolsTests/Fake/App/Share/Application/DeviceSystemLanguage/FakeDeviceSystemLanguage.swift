//
//  FakeDeviceSystemLanguage.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class FakeDeviceSystemLanguage: DeviceSystemLanguageInterface {
    
    private let deviceLocale: Locale
    
    init(deviceLocale: Locale) {
        
        self.deviceLocale = deviceLocale
    }
    
    static func getEnglishDevice() -> DeviceSystemLanguageInterface {
        return FakeDeviceSystemLanguage(deviceLocale: Locale(identifier: "en"))
    }
    
    func getLocale() -> Locale {
        
        return deviceLocale
    }
}
