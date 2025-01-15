//
//  RemoteConfigDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/14/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation

struct RemoteConfigDataModel {
    
    let globalActivityIsEnabled: Bool
    let id: String
    let updatedAt: Date
}

extension RemoteConfigDataModel {
    
    init(realmObject: RealmRemoteConfigObject) {
        
        globalActivityIsEnabled = realmObject.globalActivityIsEnabled
        id = realmObject.id
        updatedAt = realmObject.updatedAt
    }
}
