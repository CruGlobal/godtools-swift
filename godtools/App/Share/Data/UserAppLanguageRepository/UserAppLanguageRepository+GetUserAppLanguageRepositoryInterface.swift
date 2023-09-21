//
//  UserAppLanguageRepository+GetUserAppLanguageRepositoryInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

extension UserAppLanguageRepository: GetUserAppLanguageRepositoryInterface {
    
    func getUserAppLanguagePublisher() -> AnyPublisher<AppLanguageDomainModel?, Never> {
        
        return Just(nil)
            .eraseToAnyPublisher()
    }
}
