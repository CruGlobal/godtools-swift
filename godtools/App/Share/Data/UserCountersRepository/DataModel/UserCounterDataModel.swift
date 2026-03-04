//
//  UserCounterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserCounterDataModel {
    
    let id: String
    let latestCountFromAPI: Int
    let incrementValue: Int
    
    init(realmUserCounter: RealmUserCounter) {
        
        id = realmUserCounter.id
        latestCountFromAPI = realmUserCounter.latestCountFromAPI
        incrementValue = realmUserCounter.incrementValue
    }
}
