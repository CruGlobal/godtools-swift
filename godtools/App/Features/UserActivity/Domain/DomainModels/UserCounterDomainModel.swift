//
//  UserCounterDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/5/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct UserCounterDomainModel: Sendable {
    
    let id: String
    let count: Int
    
    init(id: String, count: Int) {
        
        self.id = id
        self.count = count
    }
}
