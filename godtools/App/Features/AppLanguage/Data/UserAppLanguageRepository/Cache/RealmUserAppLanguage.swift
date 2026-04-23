//
//  RealmUserAppLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 9/25/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmUserAppLanguage: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var languageId: BCP47LanguageIdentifier = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmUserAppLanguage {
    
    func mapFrom(model: UserAppLanguageDataModel) {
        id = model.id
        languageId = model.languageId
    }
    
    static func createNewFrom(model: UserAppLanguageDataModel) -> RealmUserAppLanguage {
        let object = RealmUserAppLanguage()
        object.mapFrom(model: model)
        return object
    }
    
    func toModel() -> UserAppLanguageDataModel {
        return UserAppLanguageDataModel(
            id: id,
            languageId: languageId
        )
    }
}
