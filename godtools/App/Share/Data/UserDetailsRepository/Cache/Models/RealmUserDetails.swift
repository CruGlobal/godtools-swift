//
//  RealmUserDetails.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserDetails: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date?
    @objc dynamic var familyName: String?
    @objc dynamic var givenName: String?
    @objc dynamic var name: String?
    @objc dynamic var ssoGuid: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: UserDetailsDataModelType) {
        
        id = model.id
        createdAt = model.createdAt
        familyName = model.familyName
        givenName = model.givenName
        name = model.name
        ssoGuid = model.ssoGuid
    }
}
