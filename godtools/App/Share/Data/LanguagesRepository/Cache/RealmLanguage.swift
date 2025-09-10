//
//  RealmLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguage: Object, IdentifiableRealmObject, LanguageDataModelInterface {
    
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
    
    func mapFrom(interface: LanguageDataModelInterface) {
        code = interface.code
        directionString = interface.directionString
        id = interface.id
        name = interface.name
        type = interface.type
        forceLanguageName = interface.forceLanguageName
    }
    
    static func createNewFrom(interface: LanguageDataModelInterface) -> RealmLanguage {
        let realmLanguage = RealmLanguage()
        realmLanguage.mapFrom(interface: interface)
        return realmLanguage
    }
}
