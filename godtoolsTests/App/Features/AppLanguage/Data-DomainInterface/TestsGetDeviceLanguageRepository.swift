//
//  TestsGetDeviceLanguageRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsGetDeviceLanguageRepository: GetDeviceAppLanguageRepositoryInterface {
    
    private let deviceLanguageCode: LanguageCodeDomainModel
    
    init(deviceLanguageCode: LanguageCodeDomainModel) {
        
        self.deviceLanguageCode = deviceLanguageCode
    }
    
    func getDeviceAppLanguage() -> AppLanguageCodeDomainModel {
        
        return deviceLanguageCode.value
    }
}
