//
//  GlobalAnalyticsApiInterface.swift
//  godtools
//
//  Created by Levi Eggert on 5/29/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation
import RequestOperation

protocol GlobalAnalyticsApiInterface: Sendable {
    
    func getGlobalAnalytics(requestPriority: RequestPriority) async throws -> MobileContentGlobalAnalyticsCodable?
}
