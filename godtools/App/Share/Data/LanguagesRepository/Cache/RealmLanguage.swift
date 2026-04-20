//
//  RealmLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift
import RepositorySync

class RealmLanguage: Object, IdentifiableRealmObject {
    
    @objc dynamic var code: String = ""
    @objc dynamic var directionString: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var forceLanguageName: Bool = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Backlink to the resource. This is automatically updated whenever this language is added to or removed from a resource's languages list. ~Levi
    // (https://www.mongodb.com/docs/realm/sdk/swift/model-data/relationships/)
    let resource = LinkingObjects(fromType: RealmResource.self, property: "languages")
    
    func mapFrom(model: LanguageDataModel) {
        code = model.code
        directionString = model.directionString
        id = model.id
        name = model.name
        type = model.type
        forceLanguageName = model.forceLanguageName
    }
    
    static func createNewFrom(model: LanguageDataModel) -> RealmLanguage {
        let realmLanguage = RealmLanguage()
        realmLanguage.mapFrom(model: model)
        return realmLanguage
    }
}

extension RealmLanguage {
    
    func toModel() -> LanguageDataModel {
        return LanguageDataModel(
            code: code,
            directionString: directionString,
            id: id,
            name: name,
            type: type,
            forceLanguageName: forceLanguageName
        )
    }
}
