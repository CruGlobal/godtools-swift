//
//  URL+DeepLinkScheme.swift
//  godtools
//
//  Created by Levi Eggert on 6/28/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

extension URL {
    
    func hostContainsDeepLinkScheme(scheme: DeepLinkSchemeType) -> Bool {
        guard let host = self.host, !host.isEmpty else {
            return false
        }
        return host == scheme.rawValue
    }
    
    func hostContainsDeepLinkSchemes(schemes: [DeepLinkSchemeType]) -> Bool {
        for scheme in schemes {
            if hostContainsDeepLinkScheme(scheme: scheme) {
                return true
            }
        }
        return false
    }
}
