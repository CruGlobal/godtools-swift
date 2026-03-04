//
//  UserCounterDataModel.swift
//  godtools
//
//  Created by Rachael Skeath on 12/20/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct UserCounterDataModel: Sendable {
    
    let count: Int
    let id: String
    let localCount: Int
    
    init(id: String, count: Int, localCount: Int) {
        
        self.id = id
        self.count = count
        self.localCount = localCount
    }
    
    init(interface: UserCounterDataModelInterface) {
        
        self.count = interface.count
        self.id = interface.id
        self.localCount = interface.localCount
    }
}
