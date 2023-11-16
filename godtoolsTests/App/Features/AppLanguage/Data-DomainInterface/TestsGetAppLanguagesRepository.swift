//
//  TestsGetAppLanguagesRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 10/11/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetAppLanguagesRepository: GetAppLanguagesRepositoryInterface {
    
    private let appLanguagesCodes: [LanguageCodeDomainModel]
    
    init(appLanguagesCodes: [LanguageCodeDomainModel]) {
        
        self.appLanguagesCodes = appLanguagesCodes
    }

    func getAppLanguagesPublisher() -> AnyPublisher<[AppLanguageDomainModel], Never> {
        
        let languages: [AppLanguageDomainModel] = appLanguagesCodes.map {
            $0.value
        }
        
        return Just(languages)
            .eraseToAnyPublisher()
    }
    
    func observeAppLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
