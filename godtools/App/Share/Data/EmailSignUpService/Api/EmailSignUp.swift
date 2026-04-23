//
//  EmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct EmailSignUp: Sendable {
    
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegistered: Bool
}

extension EmailSignUp {
    
    func toModel(id: String) -> EmailSignUpDataModel {
        return EmailSignUpDataModel(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            isRegistered: isRegistered
        )
    }
}
