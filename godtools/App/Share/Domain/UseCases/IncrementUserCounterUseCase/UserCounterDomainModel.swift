//
//  UserCounterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct UserCounterDomainModel {
    
    let id: String
    let count: Int
    
    init(dataModel: UserCounterDataModel) {
        
        id = dataModel.id
        count = dataModel.latestCountFromAPI + dataModel.incrementValue
    }
}
