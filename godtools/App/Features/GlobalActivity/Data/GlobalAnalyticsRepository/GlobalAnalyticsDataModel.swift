//
//  GlobalAnalyticsDataModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/20/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct GlobalAnalyticsDataModel: Sendable {
    
    let id: String
    let createdAt: Date
    let countries: Int
    let gospelPresentations: Int
    let launches: Int
    let users: Int
    let type: String
}
