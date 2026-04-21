//
//  RealmFollowUp.swift
//  godtools
//
//  Created by Levi Eggert on 7/1/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmFollowUp: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var destinationId: Int = -1
    @objc dynamic var languageId: Int = -1
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: FollowUpDataModel) {
        
        id = model.id
        name = model.name
        email = model.email
        destinationId = model.destinationId
        languageId = model.languageId
    }
    
    static func createNewFrom(model: FollowUpDataModel) -> RealmFollowUp {
        let object = RealmFollowUp()
        object.mapFrom(model: model)
        return object
    }
}

extension RealmFollowUp {
    func toModel() -> FollowUpDataModel {
        return FollowUpDataModel(
            id: id,
            name: name,
            email: email,
            destinationId: destinationId,
            languageId: languageId
        )
    }
}
