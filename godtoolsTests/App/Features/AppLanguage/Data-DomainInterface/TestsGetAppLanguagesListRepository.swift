//
//  TestsGetAppLanguagesListRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetAppLanguagesListRepository: GetAppLanguagesListRepositoryInterface {
    
    private let appLanguagesCodes: [LanguageCodeDomainModel]
    
    init(appLanguagesCodes: [LanguageCodeDomainModel]) {
        
        self.appLanguagesCodes = appLanguagesCodes
    }

    func getLanguagesPublisher() -> AnyPublisher<[AppLanguageCodeDomainModel], Never> {
        
        let languages: [AppLanguageCodeDomainModel] = appLanguagesCodes.map {
            $0.value
        }
        
        return Just(languages)
            .eraseToAnyPublisher()
    }
    
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
