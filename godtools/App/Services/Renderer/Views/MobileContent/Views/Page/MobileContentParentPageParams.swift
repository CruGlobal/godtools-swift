//
//  MobileContentParentPageParams.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

struct MobileContentParentPageParams {
    
    private let params: [String: String]
    
    init(page: Page) {
        
        params = page.parentPageParams
    }
    
    var activePageId: String? {
        return params[PageCollectionPage.companion.PARENT_PARAM_ACTIVE_PAGE]
    }
}
