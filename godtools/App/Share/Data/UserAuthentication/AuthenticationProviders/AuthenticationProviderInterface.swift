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
        
    func getPersistedAccessToken() -> AuthenticationProviderAccessToken?
    func authenticatePublisher(presentingViewController: UIViewController) -> AnyPublisher<AuthenticationProviderAccessToken?, Error>
    func signOutPublisher() -> AnyPublisher<Void, Error>
}
