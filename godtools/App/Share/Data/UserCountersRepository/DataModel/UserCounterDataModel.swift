//
//  UserCounterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserCounterDataModel: Sendable, UserCounterDataModelInterface {
    
    let id: String
    let latestCountFromAPI: Int
    let incrementValue: Int
    
    init(interface: UserCounterDataModelInterface) {
        
        id = interface.id
        latestCountFromAPI = interface.latestCountFromAPI
        incrementValue = interface.incrementValue
    }
}
