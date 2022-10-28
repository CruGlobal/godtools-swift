//
//  GetUserIsAuthenticatedUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import OktaAuthentication

class GetUserIsAuthenticatedUseCase {
    
    private let cruOktaAuthentication: CruOktaAuthentication
    
    init(cruOktaAuthentication: CruOktaAuthentication) {
        
        self.cruOktaAuthentication = cruOktaAuthentication
    }
    
    func getUserIsAuthenticated() -> Bool {
        
        return cruOktaAuthentication.refreshTokenExists && cruOktaAuthentication.getAccessTokenFromPersistentStore() != nil
    }
}
