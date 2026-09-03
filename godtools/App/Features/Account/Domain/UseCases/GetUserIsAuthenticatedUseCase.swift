//
//  GetUserIsAuthenticatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import Combine

final class GetUserIsAuthenticatedUseCase: Sendable {
    
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication) {
        
        self.userAuthentication = userAuthentication
    }
    
    @MainActor func execute() -> AnyPublisher<UserIsAuthenticatedDomainModel, Error> {
        
        return userAuthentication
            .getIsAuthenticatedPublisher()
            .map { (isAuthenticated: Bool) in
                
                return UserIsAuthenticatedDomainModel(isAuthenticated: isAuthenticated)
            }
            .eraseToAnyPublisher()
    }
}
