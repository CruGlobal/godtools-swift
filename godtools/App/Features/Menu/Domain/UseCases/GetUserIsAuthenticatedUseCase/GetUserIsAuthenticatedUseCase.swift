//
//  GetUserIsAuthenticatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

class GetUserIsAuthenticatedUseCase {
    
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication) {
        
        self.userAuthentication = userAuthentication
    }
    
    func getIsAuthenticatedPublisher() -> AnyPublisher<UserIsAuthenticatedDomainModel, Never> {
        
        return userAuthentication.getIsAuthenticatedChangedPublisher()
            .map { (isAuthenticated: Bool) in
                
                return UserIsAuthenticatedDomainModel(isAuthenticated: isAuthenticated)
            }
            .eraseToAnyPublisher()
    }
}
