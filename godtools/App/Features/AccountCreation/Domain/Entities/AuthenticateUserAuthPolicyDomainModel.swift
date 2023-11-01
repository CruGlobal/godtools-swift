//
//  AuthenticateUserAuthPolicyDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/18/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

enum AuthenticateUserAuthPolicyDomainModel {
    
    case renewAccessTokenElseAskUserToAuthenticate(fromViewController: UIViewController)
    case renewAccessToken
}
