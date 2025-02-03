//
//  ToolDeepLinkPage+MobileContentRendererInitialPage.swift
//  godtools
//
//  Created by Levi Eggert on 3/2/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

extension ToolDeepLink {
    
    var mobileContentPage: MobileContentRendererInitialPage? {
        
        if let page = self.page {
            return .pageNumber(value: page)
        }
        else if let pageId = self.pageId {
            return .pageId(value: pageId)
        }
        
        return nil
    }
}
