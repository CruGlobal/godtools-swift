//
//  UserActivityDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct UserActivityDomainModel: Sendable {
    
    let badges: [UserActivityBadgeDomainModel]
    let stats: [UserActivityStatDomainModel]
}
