//
//  ProcessedDeepLink.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct ProcessedDeepLink: Sendable {
    
    let deepLink: ParsedDeepLinkType
    let date: Date
    let incomingDeepLink: IncomingDeepLinkType
    
    var secondsSincedProcessed: TimeInterval {
        return Date().timeIntervalSince(date)
    }
}
