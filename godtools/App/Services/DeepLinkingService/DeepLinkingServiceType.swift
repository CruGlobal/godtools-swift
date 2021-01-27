//
//  DeepLinkingServiceType.swift
//  godtools
//
//  Created by Robert Eldredge on 1/13/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol DeepLinkingServiceType {
    var processing: ObservableValue<Bool> { get }
    var completed: ObservableValue<DeepLinkingType?> { get }
    
    func processDeepLink(url: URL)
    func processAppsflyerDeepLink(data: [AnyHashable : Any])
}
