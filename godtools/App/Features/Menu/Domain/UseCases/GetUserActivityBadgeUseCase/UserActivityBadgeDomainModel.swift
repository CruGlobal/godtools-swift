//
//  UserActivityBadgeDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 1/17/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import SwiftUI

struct UserActivityBadgeDomainModel: Identifiable {
        
    let badgeText: String
    let iconBackgroundColor: Color
    let iconForegroundColor: Color
    let iconImageName: String
    let id: String
    let isEarned: Bool
    let textColor: Color
    
}
