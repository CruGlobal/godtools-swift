//
//  RealmFailedViewedResource.swift
//  godtools
//
//  Created by Levi Eggert on 6/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmFailedViewedResource: Object, FailedViewedResourceModelType {
    
    @objc dynamic var resourceId: String = ""
    @objc dynamic var failedViewsCount: Int = 0
    
    override static func primaryKey() -> String? {
        return "resourceId"
    }
}
