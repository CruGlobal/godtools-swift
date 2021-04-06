//
//  ArticleWebViewModelFlowType.swift
//  godtools
//
//  Created by Levi Eggert on 4/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum ArticleWebViewModelFlowType {
    
    case deeplink
    case tool(resource: ResourceModel)
}
