//
//  RealmUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserDetails: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date?
    @objc dynamic var familyName: String?
    @objc dynamic var givenName: String?
    @objc dynamic var name: String?
    @objc dynamic var ssoGuid: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmUserDetails {
    
    func mapFrom(model: UserDetailsDataModel) {
        
        id = model.id
        createdAt = model.createdAt
        familyName = model.familyName
        givenName = model.givenName
        name = model.name
        ssoGuid = model.ssoGuid
    }
    
    static func createNewFrom(model: UserDetailsDataModel) -> RealmUserDetails {
        let object = RealmUserDetails()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserDetailsDataModel {
        return UserDetailsDataModel(
            id: id,
            createdAt: createdAt,
            familyName: familyName,
            givenName: givenName,
            name: name,
            ssoGuid: ssoGuid
        )
    }
}
