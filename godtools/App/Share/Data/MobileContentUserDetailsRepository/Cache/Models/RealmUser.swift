//
//  RealmUser.swift
//  godtools
//
//  Created by Rachael Skeath on 11/21/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUser: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var createdAt: Date?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: UserDataModel) {
        
        id = model.id
        createdAt = model.createdAt
    }
}
