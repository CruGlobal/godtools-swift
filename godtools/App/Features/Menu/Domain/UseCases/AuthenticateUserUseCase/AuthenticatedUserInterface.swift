//
//  AuthenticatedUserInterface.swift
//  godtools
//
//  Created by Levi Eggert on 4/27/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

protocol AuthenticatedUserInterface {
    
    var email: String { get }
    var firstName: String? { get }
    var grMasterPersonId: String? { get }
    var lastName: String? { get }
    var ssoGuid: String? { get }
}
