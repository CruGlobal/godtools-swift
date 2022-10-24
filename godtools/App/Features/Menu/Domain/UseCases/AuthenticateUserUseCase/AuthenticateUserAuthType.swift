//
//  AuthenticateUserAuthType.swift
//  godtools
//
//  Created by Levi Eggert on 10/24/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

enum AuthenticateUserAuthType {
    
    case attemptToRenewAuthenticationElseAuthenticate(fromViewController: UIViewController)
    case attemptToRenewAuthenticationOnly
}
