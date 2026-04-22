//
//  RealmEmailSignUp.swift
//  godtools
//
//  Created by Levi Eggert on 12/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmEmailSignUp: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var isRegistered: Bool = false
    
    override static func primaryKey() -> String? {
        return "email"
    }
}

extension RealmEmailSignUp {
    
    func mapFrom(model: EmailSignUpDataModel) {
        
        id = model.id
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegistered = model.isRegistered
    }
    
    static func createNewFrom(model: EmailSignUpDataModel) -> RealmEmailSignUp {
        let object = RealmEmailSignUp()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmEmailSignUp {
   
    func toModel() -> EmailSignUpDataModel {
        return EmailSignUpDataModel(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            isRegistered: isRegistered
        )
    }
}
