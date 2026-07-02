//
//  EmailSignUpDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/22/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct EmailSignUpDataModel: Sendable {
    
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegistered: Bool
    
    init(id: String, email: String, firstName: String?, lastName: String?, isRegistered: Bool) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.isRegistered = isRegistered
    }
    
    init(id: String, emailSignUp: EmailSignUp) {
        self.id = id
        self.email = emailSignUp.email
        self.firstName = emailSignUp.firstName
        self.lastName = emailSignUp.lastName
        self.isRegistered = emailSignUp.isRegistered
    }
    
    func toEmailSignUp() -> EmailSignUp {
        return EmailSignUp(email: email, firstName: firstName, lastName: lastName, isRegistered: isRegistered)
    }
}
