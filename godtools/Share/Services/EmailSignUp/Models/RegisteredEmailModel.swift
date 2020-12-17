//
//  RegisteredEmailModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct RegisteredEmailModel: RegisteredEmailModelType {
    
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let isRegisteredWithRemoteApi: Bool
    
    init(email: String, firstName: String?, lastName: String?, isRegisteredWithRemoteApi: Bool) {
        
        self.id = UUID().uuidString
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.isRegisteredWithRemoteApi = isRegisteredWithRemoteApi
    }
    
    init(model: RegisteredEmailModelType) {
        
        id = model.id
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegisteredWithRemoteApi = model.isRegisteredWithRemoteApi
    }
}
