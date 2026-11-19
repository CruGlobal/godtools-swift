//
//  DynalinkDeferredDeepLinkInterface.swift
//  godtools
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol DynalinkDeferredDeepLinkInterface: Sendable {

    func getDeepLinkUrl() async -> URL?
}
