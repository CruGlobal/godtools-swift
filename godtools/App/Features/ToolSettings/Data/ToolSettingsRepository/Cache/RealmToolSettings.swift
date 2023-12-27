//
//  RealmToolSettings.swift
//  godtools
//
//  Created by Levi Eggert on 12/12/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmToolSettings: Object, IdentifiableRealmObject {
    
    @objc dynamic var id: String = ""
    @objc dynamic var parallelLanguageId: String?
    @objc dynamic var primaryLanguageId: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
