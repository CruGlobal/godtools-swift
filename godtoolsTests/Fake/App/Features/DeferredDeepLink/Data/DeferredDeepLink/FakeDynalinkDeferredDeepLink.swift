//
//  FakeDynalinkDeferredDeepLink.swift
//  godtoolsTests
//
//  Created by Claude on 9/24/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
@testable import godtools

struct FakeDynalinkDeferredDeepLink: DynalinkDeferredDeepLinkInterface {

    private let deepLinkUrl: URL?

    init(deepLinkUrl: URL?) {

        self.deepLinkUrl = deepLinkUrl
    }

    func getDeepLinkUrl() async -> URL? {

        return deepLinkUrl
    }
}
