//
//  RealmFavoritedResource.swift
//  godtools
//
//  Created by Levi Eggert on 6/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFavoritedResource: Object, FavoritedResourceModelType {
    
    @objc dynamic var resourceId: String = ""
    @objc dynamic var sortOrder: Int = -1
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}
