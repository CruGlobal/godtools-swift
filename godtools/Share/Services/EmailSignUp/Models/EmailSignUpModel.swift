//
//  EmailSignUpModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct EmailSignUpModel: EmailSignUpModelType {
    
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegistered: Bool
    
    init(email: String, firstName: String?, lastName: String?) {
        
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.isRegistered = false
    }
    
    init(model: EmailSignUpModelType) {
        
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegistered = model.isRegistered
    }
    
    init(model: EmailSignUpModelType, isRegistered: Bool) {
        
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        self.isRegistered = isRegistered
    }
}
