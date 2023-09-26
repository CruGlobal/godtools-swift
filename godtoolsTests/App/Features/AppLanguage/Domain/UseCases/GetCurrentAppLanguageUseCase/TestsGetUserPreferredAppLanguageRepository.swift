//
//  TestsGetUserPreferredAppLanguageRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsGetUserPreferredAppLanguageRepository: GetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageCode: LanguageCodeDomainModel?
    
    init(userAppLanguageCode: LanguageCodeDomainModel?) {
        
        self.userAppLanguageCode = userAppLanguageCode
    }
    
    func getUserPreferredAppLanguage() -> AppLanguageCodeDomainModel? {
        
        return userAppLanguageCode?.value
    }
}
