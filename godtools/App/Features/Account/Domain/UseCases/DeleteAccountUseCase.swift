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
    private let deleteUserDetails: DeleteUserDetailsInterface
    
    init(userAuthentication: UserAuthentication, deleteUserDetails: DeleteUserDetailsInterface) {
        
        self.userAuthentication = userAuthentication
        self.deleteUserDetails = deleteUserDetails
    }
    
    func deleteAccountPublisher() -> AnyPublisher<Void, Error> {
                
        return deleteUserDetails.deleteUserDetailsPublisher()
            .flatMap({ (void: Void) -> AnyPublisher<Void, Error> in
                                
                return self.userAuthentication.signOutPublisher()
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
