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
    
    func deleteAccountPublisher() -> AnyPublisher<Void, URLResponseError> {
                
        return userDetailsRepository.deleteAuthorizedUserDetails()
            .flatMap({ (void: Void) -> AnyPublisher<Void, URLResponseError> in
                                
                return self.userAuthentication.signOutPublisher()
                    .mapError { (error: Error) in
                        return .otherError(error: error)
                    }
                    .eraseToAnyPublisher()
            })
            .flatMap({ (void: Void) -> AnyPublisher<Void, URLResponseError> in
                        
                self.mobileContentAuthTokenRepository.deleteCachedAuthToken()
                
                return Just(void).setFailureType(to: URLResponseError.self)
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
