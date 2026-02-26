//
//  RealmMobileContentAuthToken.swift
//  godtools
//
//  Created by Levi Eggert on 5/30/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmMobileContentAuthToken: Object, IdentifiableRealmObject, MobileContentAuthTokenDataModelInterface {
    
    @objc dynamic var expirationDate: Date?
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    
    override static func primaryKey() -> String? {
        return "userId"
    }
    
    func mapFrom(interface: MobileContentAuthTokenDataModelInterface) {
        
        expirationDate = interface.expirationDate
        id = interface.id
        userId = interface.userId
    }
    
    static func createNewFrom(interface: MobileContentAuthTokenDataModelInterface) -> RealmMobileContentAuthToken {
        let object = RealmMobileContentAuthToken()
        object.mapFrom(interface: interface)
        return object
    }
}
