//
//  DeleteAccountUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 5/23/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class DeleteAccountUseCase {
    
    private let userAuthentication: UserAuthentication
    private let userDetailsRepository: UserDetailsRepository
    private let mobileContentAuthTokenRepository: MobileContentAuthTokenRepository
    
    init(userAuthentication: UserAuthentication, userDetailsRepository: UserDetailsRepository, mobileContentAuthTokenRepository: MobileContentAuthTokenRepository) {
        
        self.userAuthentication = userAuthentication
        self.userDetailsRepository = userDetailsRepository
        self.mobileContentAuthTokenRepository = mobileContentAuthTokenRepository
    }
    
    func deleteAccountPublisher() -> AnyPublisher<Void, Error> {
                
        return userDetailsRepository.deleteAuthorizedUserDetails()
            .flatMap({ (void: Void) -> AnyPublisher<Void, Error> in
                                
                return self.userAuthentication.signOutPublisher()
                    .eraseToAnyPublisher()
            })
            .flatMap({ (void: Void) -> AnyPublisher<Void, Error> in
                        
                self.mobileContentAuthTokenRepository.deleteCachedAuthToken()
                
                return Just(void).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
