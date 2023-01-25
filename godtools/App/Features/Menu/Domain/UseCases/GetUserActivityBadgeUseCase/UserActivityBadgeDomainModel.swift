//
//  UserActivityBadgeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser
import SwiftUI

struct UserActivityBadgeDomainModel {
        
    let badgeText: String
    let badgeType: Badge.BadgeType
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let iconImageName: String
    let isEarned: Bool
    let variant: Int
}

extension UserActivityBadgeDomainModel: Identifiable {
    
    var id: String {
        return "\(badgeType.name)_\(variant)"
    }
}
