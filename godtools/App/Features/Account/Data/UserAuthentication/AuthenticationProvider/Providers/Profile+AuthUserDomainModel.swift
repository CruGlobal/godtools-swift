//
//  Profile+AuthUserDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 6/25/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension Profile {
    
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
