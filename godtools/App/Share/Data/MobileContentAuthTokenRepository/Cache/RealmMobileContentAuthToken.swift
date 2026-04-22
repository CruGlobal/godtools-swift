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

class RealmMobileContentAuthToken: Object, IdentifiableRealmObject {
    
    @objc dynamic var expirationDate: Date?
    @objc dynamic var id: String = ""
    @objc dynamic var userId: String = ""
    
    override static func primaryKey() -> String? {
        return "userId"
    }
}

extension RealmMobileContentAuthToken {
    
    func mapFrom(model: MobileContentAuthTokenDataModel) {
        
        expirationDate = model.expirationDate
        id = model.id
        userId = model.userId
    }
    
    static func createNewFrom(model: MobileContentAuthTokenDataModel) -> RealmMobileContentAuthToken {
        let object = RealmMobileContentAuthToken()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> MobileContentAuthTokenDataModel {
    
        return MobileContentAuthTokenDataModel(
            appleRefreshToken: nil,
            expirationDate: expirationDate,
            id: id,
            token: "",
            userId: userId
        )
    }
}
