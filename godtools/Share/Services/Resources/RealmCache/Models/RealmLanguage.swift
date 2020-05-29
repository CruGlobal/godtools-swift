//
//  RealmLanguage.swift
//  godtools
//
//  Created by Levi Eggert on 5/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmLanguage: Object, LanguageType {
    
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var attributes: RealmLanguageAttributes?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case attributes = "attributes"
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
