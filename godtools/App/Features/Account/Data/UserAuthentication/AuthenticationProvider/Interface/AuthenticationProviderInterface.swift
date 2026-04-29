//
//  AuthenticationProviderInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

protocol AuthenticationProviderInterface {
    
    @MainActor func providerAuthenticate(presentingViewController: UIViewController) async throws -> AuthenticationProviderResponse
    func providerRenewToken() async throws -> AuthenticationProviderResponse
    func providerSignOut()
    func providerGetAuthUser() async throws -> AuthUserDomainModel?
}
