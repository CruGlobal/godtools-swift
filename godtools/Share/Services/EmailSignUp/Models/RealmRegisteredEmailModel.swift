//
//  RealmRegisteredEmailModel.swift
//  godtools
//
//  Created by Levi Eggert on 12/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmRegisteredEmailModel: Object, RegisteredEmailModelType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var isRegisteredWithRemoteApi: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: RegisteredEmailModelType) {
        
        id = model.id
        email = model.email
        firstName = model.firstName
        lastName = model.lastName
        isRegisteredWithRemoteApi = model.isRegisteredWithRemoteApi
    }
}
