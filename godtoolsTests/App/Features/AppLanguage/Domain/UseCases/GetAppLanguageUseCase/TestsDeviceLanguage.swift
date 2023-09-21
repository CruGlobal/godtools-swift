//
//  TestsDeviceLanguage.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsDeviceLanguage: GetDeviceLanguageInterface {
    
    private let deviceLanguageCode: LanguageCode
    
    init(deviceLanguageCode: LanguageCode) {
        
        self.deviceLanguageCode = deviceLanguageCode
    }
    
    func getDeviceLanguage() -> DeviceLanguageDomainModel {
        return DeviceLanguageDomainModel(languageCode: deviceLanguageCode.value)
    }
}
