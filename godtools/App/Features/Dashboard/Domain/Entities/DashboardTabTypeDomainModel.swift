//
//  DashboardTabTypeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 10/18/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

enum DashboardTabTypeDomainModel: String {
    
    case lessons
    case favorites
    case tools
}

extension DashboardTabTypeDomainModel: Identifiable {
    var id: String {
        return rawValue
    }
}
