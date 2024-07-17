//
//  MockDeviceSystemLanguage.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 4/29/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class MockDeviceSystemLanguage: DeviceSystemLanguageInterface {
    
    private let deviceLocale: Locale
    
    init(deviceLocale: Locale) {
        
        self.deviceLocale = deviceLocale
    }
    
    static func getMockEnglishDevice() -> DeviceSystemLanguageInterface {
        return MockDeviceSystemLanguage(deviceLocale: Locale(identifier: "en"))
    }
    
    func getLocale() -> Locale {
        
        return deviceLocale
    }
}
