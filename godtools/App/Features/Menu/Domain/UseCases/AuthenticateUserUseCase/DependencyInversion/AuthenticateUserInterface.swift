//
//  AuthenticateUserInterface.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

protocol AuthenticateUserInterface {
    
    func authenticateUserPublisher(authType: AuthenticateUserAuthType, authPlatform: AuthenticateUserAuthPlatform, authPolicy: AuthenticateUserAuthPolicy) -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel>
    func renewAuthenticationPublisher() -> AnyPublisher<AuthUserDomainModel?, AuthErrorDomainModel>
}
