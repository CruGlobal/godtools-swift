//
//  Profile+AuthUserDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/12/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import SocialAuthentication

extension FacebookProfile {
    
    func toAuthUserDomainModel() -> AuthUserDomainModel {
        
        AuthUserDomainModel(
            email: email ?? "",
            firstName: firstName,
            grMasterPersonId: nil,
            lastName: lastName,
            name: name,
            ssoGuid: nil
        )
    }
}
