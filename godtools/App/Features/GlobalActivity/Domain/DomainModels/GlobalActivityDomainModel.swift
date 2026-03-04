//
//  GlobalActivityDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

struct GlobalActivityDomainModel: Sendable {
    
    let count: String
    let label: String
}

extension GlobalActivityDomainModel: Identifiable {
    
    var id: String {
        return label
    }
}
