//
//  RealmToolScreenShareView.swift
//  godtools
//
//  Created by Levi Eggert on 11/6/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmToolScreenShareView: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var numberOfViews: Int = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
