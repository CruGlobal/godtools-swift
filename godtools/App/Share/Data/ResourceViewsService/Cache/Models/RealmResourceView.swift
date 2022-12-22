//
//  RealmResourceView.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmResourceView: Object, ResourceViewModelType {
    
    @objc dynamic var resourceId: String = ""
    @objc dynamic var quantity: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}
