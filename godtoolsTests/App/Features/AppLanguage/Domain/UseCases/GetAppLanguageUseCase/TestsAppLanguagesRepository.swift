//
//  TestsAppLanguagesRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsAppLanguagesRepository: GetAppLanguagesRepositoryInterface {
    
    private let appLanguagesCodes: [LanguageCode]
    
    init(appLanguagesCodes: [LanguageCode]) {
        
        self.appLanguagesCodes = appLanguagesCodes
    }
    
    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDomainModel], Never> {
                
        let appLanguages: [AppLanguageDomainModel] = appLanguagesCodes.map({
            return AppLanguageDomainModel(direction: .leftToRight, languageCode: $0.value)
        })
        
        return Just(appLanguages)
            .eraseToAnyPublisher()
    }
}
