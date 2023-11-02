//
//  AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit
import Combine

protocol AuthenticationProviderInterface {
        
    func getPersistedResponse() -> AuthenticationProviderResponse?
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderResponse, Error>
    func renewTokenPublisher() -> AnyPublisher<AuthenticationProviderResponse, Error>
    func signOutPublisher() -> AnyPublisher<Void, Error>
    func getAuthUserPublisher() -> AnyPublisher<AuthUserDomainModel?, Error>
}
