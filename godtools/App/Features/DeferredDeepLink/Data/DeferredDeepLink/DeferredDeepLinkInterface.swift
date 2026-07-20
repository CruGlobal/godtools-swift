//
//  DeferredDeepLinkInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol DeferredDeepLinkInterface {
    
    func getDeepLinkUrl() async -> URL?
}
