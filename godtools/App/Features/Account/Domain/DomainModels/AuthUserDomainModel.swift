//
//  AuthUserDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct AuthUserDomainModel: Sendable {
    
    let email: String
    let firstName: String?
    let grMasterPersonId: String?
    let lastName: String?
    let name: String?
    let ssoGuid: String?
}
