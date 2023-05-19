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
    
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication) {
        
        self.userAuthentication = userAuthentication
    }
    
    func getProfileNamePublisher() -> AnyPublisher<AccountProfileNameDomainModel, Never> {
     
        return userAuthentication.getAuthUserPublisher()
            .catch({ (error: Error) -> AnyPublisher<AuthUserDomainModel?, Never> in
                
                return Just(nil)
                    .eraseToAnyPublisher()
            })
            .flatMap({ (authUser: AuthUserDomainModel?) -> AnyPublisher<AccountProfileNameDomainModel, Never> in
                                
                let profileName: String
                
                if let firstName = authUser?.firstName, let lastName = authUser?.lastName {
                    profileName = firstName + " " + lastName
                }
                else if let firstName = authUser?.firstName {
                    profileName = firstName
                }
                else if let lastName = authUser?.lastName {
                    profileName = lastName
                }
                else {
                    profileName = ""
                }
                
                return Just(AccountProfileNameDomainModel(value: profileName))
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }
}
