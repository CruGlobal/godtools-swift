//
//  EmailSignUpModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct EmailSignUpModel: Sendable {
    
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegistered: Bool
}
