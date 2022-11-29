//
//  RealmUserCounter.swift
//  godtools
//
//  Created by Rachael Skeath on 11/29/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUserCounter: Object {
    
    @objc dynamic var id: String = ""
    @objc dynamic var count: Int = 0
    @objc dynamic var decayedCount: Double = 0
    @objc dynamic var lastDecay: Date?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(model: UserCounterDataModel) {
        
        id = model.id
        count = model.count
        decayedCount = model.decayedCount ?? 0
        lastDecay = model.lastDecay
    }
}
