//
//  RealmEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEmailSignUp: Object, EmailSignUpModelType {
    
    @objc dynamic var email: String = ""
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var isRegistered: Bool = false
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    func mapFrom(model: EmailSignUpModelType) {
        
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegistered = model.isRegistered
    }
}
