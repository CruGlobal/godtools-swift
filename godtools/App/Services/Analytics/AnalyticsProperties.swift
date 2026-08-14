//
//  AnalyticsProperties.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

struct AnalyticsProperties: Sendable {
    
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let appLanguage: String?
    let contentLanguage: String?
    let secondaryContentLanguage: String?
}
