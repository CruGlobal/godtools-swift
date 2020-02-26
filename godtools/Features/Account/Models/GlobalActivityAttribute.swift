//
//  GlobalActivityAttribute.swift
//  godtools
//
//  Created by Levi Eggert on 2/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

enum GlobalActivityType {
    case users
    case countries
    case launches
    case gospelPresentation
}

struct GlobalActivityAttribute {
    let activityType: GlobalActivityType
    let count: Int
}
