//
//  Category.swift
//  godtools
//
//  Created by Igor Ostriz on 15/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//



import Foundation
import RealmSwift

class Category: Object {

    @objc dynamic var remoteId = ""
    @objc dynamic var title = ""
    
    override static func primaryKey() -> String {
        return "remoteId"
    }
}
