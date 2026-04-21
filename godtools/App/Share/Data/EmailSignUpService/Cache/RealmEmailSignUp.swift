//
//  RealmEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEmailSignUp: Object {
    
    @objc dynamic var email: String = ""
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var isRegistered: Bool = false
    
    override static func primaryKey() -> String? {
        return "email"
    }
    
    func mapFrom(model: EmailSignUp) {
        
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegistered = model.isRegistered
    }
    
    static func createNewFrom(model: EmailSignUp) -> RealmEmailSignUp {
        let object = RealmEmailSignUp()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmEmailSignUp {
    func toModel() -> EmailSignUp {
        return EmailSignUp(
            email: email,
            firstName: firstName,
            lastName: lastName,
            isRegistered: isRegistered
        )
    }
}
