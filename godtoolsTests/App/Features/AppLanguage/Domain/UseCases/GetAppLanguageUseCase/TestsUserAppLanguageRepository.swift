//
//  TestsUserAppLanguageRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsUserAppLanguageRepository: GetUserAppLanguageRepositoryInterface {
    
    private let userAppLanguage: AppLanguageDomainModel?
    
    init(userAppLanguage: AppLanguageDomainModel?) {
        
        self.userAppLanguage = userAppLanguage
    }
    
    func getUserAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel?, Never> {
        
        return Just(userAppLanguage)
            .eraseToAnyPublisher()
    }
}
