//
//  AuthenticateUserAuthPlatformDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

enum AuthenticateUserAuthPlatformDomainModel {
    
    case apple
    case facebook
    case google
}

extension AuthenticateUserAuthPlatformDomainModel {
    
    func toProvider() -> AuthenticationProviderType {
        switch self {
        case .apple:
            return .apple
        case .facebook:
            return .facebook
        case .google:
            return .google
        }
    }
}
