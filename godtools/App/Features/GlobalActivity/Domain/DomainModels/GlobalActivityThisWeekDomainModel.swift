//
//  GlobalActivityThisWeekDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct GlobalActivityThisWeekDomainModel {
    
    let count: String
    let label: String
}

extension GlobalActivityThisWeekDomainModel: Identifiable {
    
    var id: String {
        return label
    }
}
