//
//  RealmLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguage: Object, LanguageModelType {
    
    @objc dynamic var code: String = ""
    @objc dynamic var direction: String = ""
    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var type: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    // Backlink to the resource. This is automatically updated whenever this language is added to or removed from a resource's languages list. ~Levi
    // (https://www.mongodb.com/docs/realm/sdk/swift/model-data/relationships/)
    let resource = LinkingObjects(fromType: RealmResource.self, property: "languages")
    
    func mapFrom(model: LanguageModel) {
        
        code = model.code
        direction = model.direction
        id = model.id
        name = model.name
        type = model.type
    }
}
