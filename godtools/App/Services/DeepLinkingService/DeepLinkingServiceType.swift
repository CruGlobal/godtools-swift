//
//  DeepLinkingServiceType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingServiceType {
        
    var deepLinkObserver: PassthroughValue<ParsedDeepLinkType?> { get }
    
    func parseDeepLink(incomingDeepLink: IncomingDeepLinkType) -> ParsedDeepLinkType?
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool
}
