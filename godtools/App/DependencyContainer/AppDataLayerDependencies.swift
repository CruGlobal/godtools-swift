//
//  AppDataLayerDependencies.swift
//  godtools
//
//  Created by Levi Eggert on 7/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class AppDataLayerDependencies {
    
    private let sharedRealmDatabase: RealmDatabase = RealmDatabase()
    private let sharedIgnoreCacheSession: IgnoreCacheSession = IgnoreCacheSession()
    
    init() {
        
    }
}
