//
//  AuthenticateUserAuthPlatform+AuthenticationProviderType.swift
//  godtools
//
//  Created by Levi Eggert on 9/19/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension AuthenticateUserAuthPlatform {
    
    func toAuthenticationProviderType() -> AuthenticationProviderType {
        
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
