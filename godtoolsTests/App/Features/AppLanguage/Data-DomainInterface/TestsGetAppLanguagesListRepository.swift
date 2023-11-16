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
    
    private let appLanguages: [AppLanguageListItemDomainModel]
    
    init(appLanguages: [AppLanguageListItemDomainModel]) {
        
        self.appLanguages = appLanguages
    }

    func getLanguagesPublisher(currentAppLanguage: AppLanguageDomainModel) -> AnyPublisher<[AppLanguageListItemDomainModel], Never> {
        
        return Just(appLanguages)
            .eraseToAnyPublisher()
    }
    
    func observeLanguagesChangedPublisher() -> AnyPublisher<Void, Never> {
        
        return Just(Void())
            .eraseToAnyPublisher()
    }
}
