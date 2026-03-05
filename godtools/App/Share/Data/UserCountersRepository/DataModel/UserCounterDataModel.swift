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
    
    init(id: String, count: Int) {
        
        self.id = id
        self.count = count
    }
    
    init(interface: UserCounterDataModelInterface) {
        
        self.count = interface.count
        self.id = interface.id
    }
}
