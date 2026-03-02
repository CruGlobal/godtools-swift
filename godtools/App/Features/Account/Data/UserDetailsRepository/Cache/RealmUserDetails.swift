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

class RealmUserDetails: Object, IdentifiableRealmObject, UserDetailsDataModelInterface {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date?
    @objc dynamic var familyName: String?
    @objc dynamic var givenName: String?
    @objc dynamic var name: String?
    @objc dynamic var ssoGuid: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(interface: UserDetailsDataModelInterface) {
        
        id = interface.id
        createdAt = interface.createdAt
        familyName = interface.familyName
        givenName = interface.givenName
        name = interface.name
        ssoGuid = interface.ssoGuid
    }
    
    static func createNewFrom(interface: UserDetailsDataModelInterface) -> RealmUserDetails {
        let object = RealmUserDetails()
        object.mapFrom(interface: interface)
        return object
    }
}
