//
//  URL+DeepLinkHost.swift
//  godtools
//
//  Created by Levi Eggert on 2/6/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension URL {
    
    func containsDeepLinkHost(deepLinkHost: DeepLinkHostType) -> Bool {
        guard let host = self.host, !host.isEmpty else {
            return false
        }
        return host.contains(deepLinkHost.rawValue)
    }
    
    func containsDeepLinkHosts(deepLinkHosts: [DeepLinkHostType]) -> Bool {
        for deepLinkHost in deepLinkHosts {
            if containsDeepLinkHost(deepLinkHost: deepLinkHost) {
                return true
            }
        }
        return false
    }
}
