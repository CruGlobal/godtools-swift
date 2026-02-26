//
//  AccountStringsDomainModel.swift
//  godtools
//
//  Created by Rachael Skeath on 2/17/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct AccountStringsDomainModel {
    
    let navTitle: String
    let activityButtonTitle: String
    let myActivitySectionTitle: String
    let badgesSectionTitle: String
    let globalActivityButtonTitle: String
    let globalAnalyticsTitle: String
    
    static var emptyValue: AccountStringsDomainModel {
        return AccountStringsDomainModel(navTitle: "", activityButtonTitle: "", myActivitySectionTitle: "", badgesSectionTitle: "", globalActivityButtonTitle: "", globalAnalyticsTitle: "")
    }
}
