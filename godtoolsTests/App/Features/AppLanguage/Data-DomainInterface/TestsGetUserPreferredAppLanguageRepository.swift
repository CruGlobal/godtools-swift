//
//  TestsGetUserPreferredAppLanguageRepository.swift
//  godtoolsTests
//
//  Created by Levi Eggert on 9/26/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
@testable import godtools
import Combine

class TestsGetUserPreferredAppLanguageRepository: GetUserPreferredAppLanguageRepositoryInterface {
    
    private let userAppLanguageCode: LanguageCodeDomainModel?
    
    init(userAppLanguageCode: LanguageCodeDomainModel?) {
        
        self.userAppLanguageCode = userAppLanguageCode
    }
    
    func getLanguagePublisher() -> AnyPublisher<AppLanguageCodeDomainModel?, Never> {
        
        return Just(userAppLanguageCode?.value)
            .eraseToAnyPublisher()
    }
}
