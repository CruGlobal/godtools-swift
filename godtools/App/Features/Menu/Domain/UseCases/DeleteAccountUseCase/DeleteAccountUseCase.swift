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
    
    init(userAuthentication: UserAuthentication, userDetailsRepository: UserDetailsRepository) {
        
        self.userAuthentication = userAuthentication
        self.userDetailsRepository = userDetailsRepository
    }
    
    func deleteAccountPublisher() -> AnyPublisher<Void, Error> {
                
        return userDetailsRepository.deleteAuthorizedUserDetails()
            .flatMap({ (void: Void) -> AnyPublisher<Void, Error> in
                                
                return self.userAuthentication.signOutPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
