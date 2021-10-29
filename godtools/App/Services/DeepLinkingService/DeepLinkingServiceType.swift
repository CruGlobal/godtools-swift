//
//  DeepLinkingServiceType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingServiceType {
        
    func addDeepLinkObserver(object: NSObject, onObserve: @escaping PassthroughValue<ParsedDeepLinkType?>.Handler)
    func removeDeepLinkObserver(object: NSObject)
    func parseDeepLinkAndNotify(incomingDeepLink: IncomingDeepLinkType) -> Bool
}
