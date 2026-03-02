//
//  GIDProfileData+ToAuthUserDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication
import GoogleSignIn

extension GIDProfileData {
    
    func toAuthUserDomainModel() -> AuthUserDomainModel {
        
        return AuthUserDomainModel(
            email: email,
            firstName: givenName,
            grMasterPersonId: nil,
            lastName: familyName,
            name: name,
            ssoGuid: nil
        )
    }
}
