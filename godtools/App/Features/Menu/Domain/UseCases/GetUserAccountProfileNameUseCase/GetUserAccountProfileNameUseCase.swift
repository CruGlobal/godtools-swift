//
//  GetUserAccountProfileNameUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserAccountProfileNameUseCase {
    
    private let userDetailsRepository: UserDetailsRepository
    
    init(userDetailsRepository: UserDetailsRepository) {
        
        self.userDetailsRepository = userDetailsRepository
    }
    
    private func getEmptyProfileName() -> AccountProfileNameDomainModel {
        return AccountProfileNameDomainModel(value: "")
    }
    
    func getProfileNamePublisher() -> AnyPublisher<AccountProfileNameDomainModel, Never> {
     
        return userDetailsRepository.getAuthUserDetailsChangedPublisher()
            .map { _ in
                
                guard let cachedAuthUserDetails = self.userDetailsRepository.getCachedAuthUserDetails(),
                      let name = cachedAuthUserDetails.name else {
                    
                    return self.getEmptyProfileName()
                }
                
                return AccountProfileNameDomainModel(value: name)
            }
            .eraseToAnyPublisher()
    }
}
