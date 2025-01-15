//
//  RealmRemoteConfigObject.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import RealmSwift

class RealmRemoteConfigObject: Object {
    
    @Persisted var globalActivityIsEnabled: Bool
    @Persisted var id: String
    @Persisted var updatedAt: Date

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func mapFrom(dataModel: RemoteConfigDataModel) {
        
        id = dataModel.id
        globalActivityIsEnabled = dataModel.globalActivityIsEnabled
        updatedAt = dataModel.updatedAt
    }
}
