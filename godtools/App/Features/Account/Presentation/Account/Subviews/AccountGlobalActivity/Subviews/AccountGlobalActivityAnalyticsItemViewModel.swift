//
//  AccountGlobalActivityAnalyticsItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/15/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

@MainActor class AccountGlobalActivityAnalyticsItemViewModel: ObservableObject {
    
    let label: String
    let count: String
    
    init(globalActivity: GlobalActivityDomainModel) {
        
        label = globalActivity.label
        count = globalActivity.count
    }
}
