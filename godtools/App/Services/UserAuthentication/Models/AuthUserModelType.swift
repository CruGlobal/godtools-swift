//
//  AuthUserModelType.swift
//  godtools
//
//  Created by Levi Eggert on 12/2/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol AuthUserModelType {
    
    var email: String { get }
    var firstName: String? { get }
    var grMasterPersonId: String? { get }
    var lastName: String? { get }
    var ssoGuid: String? { get }
}
