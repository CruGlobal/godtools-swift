//
//  NoDeferredDeepLink.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

final class NoDeferredDeepLink: DeferredDeepLinkInterface {
    
    init() {
        
    }
    
    func getDeepLinkUrl() async -> URL? {
        return nil
    }
}
