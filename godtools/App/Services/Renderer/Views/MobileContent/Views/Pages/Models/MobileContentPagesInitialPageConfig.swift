//
//  MobileContentPagesInitialPageConfig.swift
//  godtools
//
//  Created by Rachael Skeath on 10/25/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

struct MobileContentPagesInitialPageConfig {
    
    let shouldNavigateToStartPageIfLastPage: Bool
    let shouldNavigateToPreviousVisiblePageIfHiddenPage: Bool
    
    init(shouldNavigateToStartPageIfLastPage: Bool = false, shouldNavigateToPreviousVisiblePageIfHiddenPage: Bool = false) {
        
        self.shouldNavigateToStartPageIfLastPage = shouldNavigateToStartPageIfLastPage
        self.shouldNavigateToPreviousVisiblePageIfHiddenPage = shouldNavigateToPreviousVisiblePageIfHiddenPage
    }
}
