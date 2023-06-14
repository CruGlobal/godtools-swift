//
//  GetUserIsAuthenticatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class GetUserIsAuthenticatedUseCase {
    
    private let userAuthentication: UserAuthentication
    
    init(userAuthentication: UserAuthentication) {
        
        self.userAuthentication = userAuthentication
    }
    
    func getUserIsAuthenticated() -> Bool {
        
        return userAuthentication.getPersistedResponse() != nil
    }
}
