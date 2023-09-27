//
//  TestsGetAppLanguagesListRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools

class TestsGetAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface {
    
    private let appLanguagesCodes: [LanguageCodeDomainModel]
    
    init(appLanguagesCodes: [LanguageCodeDomainModel]) {
        
        self.appLanguagesCodes = appLanguagesCodes
    }
    
    func getAppLanguagesList() -> [AppLanguageCodeDomainModel] {
        
        return appLanguagesCodes.map {
            $0.value
        }
    }
}
