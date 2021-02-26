//
//  DeepLinkingServiceType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingServiceType {
    
    var completed: ObservableValue<ParsedDeepLinkType?> { get }
    
    func parseDeepLink(incomingDeepLink: IncomingDeepLinkType) -> Bool
}
