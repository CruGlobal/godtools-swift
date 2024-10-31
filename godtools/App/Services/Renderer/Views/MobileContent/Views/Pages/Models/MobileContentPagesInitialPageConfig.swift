//
//  MobileContentPagesInitialPageConfig.swift
//  godtools
//
//  Created by Rachael Skeath on 10/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct MobileContentPagesInitialPageConfig {
    
    let shouldRestartAtBeginning: Bool
    let shouldNavigateToStartPageIfLastPage: Bool
    let shouldNavigateToPreviousVisiblePageIfHiddenPage: Bool
    
    init(shouldRestartAtBeginning: Bool = false, shouldNavigateToStartPageIfLastPage: Bool = false, shouldNavigateToPreviousVisiblePageIfHiddenPage: Bool = false) {
        
        self.shouldRestartAtBeginning = shouldRestartAtBeginning
        self.shouldNavigateToStartPageIfLastPage = shouldNavigateToStartPageIfLastPage
        self.shouldNavigateToPreviousVisiblePageIfHiddenPage = shouldNavigateToPreviousVisiblePageIfHiddenPage
    }
}
