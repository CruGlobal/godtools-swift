//
//  MobileContentParentPageParams.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/25.
//  Copyright © 2025 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

struct MobileContentParentPageParams {
    
    private let params: [String: String]
    
    init?(params: [String: String]?) {
        
        guard let params = params, !params.isEmpty else {
            return nil
        }
        
        self.params = params
    }
    
    init(page: Page) {
        
        params = page.parentPageParams
    }
    
    var activePageId: String? {
        return params[PageCollectionPage.companion.PARENT_PARAM_ACTIVE_PAGE]
    }
}
