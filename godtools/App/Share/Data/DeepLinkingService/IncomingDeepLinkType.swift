//
//  IncomingDeepLinkType.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

enum IncomingDeepLinkType {
    
    case appsFlyer(data: [AnyHashable: Any])
    case url(incomingUrl: IncomingDeepLinkUrl)
}
