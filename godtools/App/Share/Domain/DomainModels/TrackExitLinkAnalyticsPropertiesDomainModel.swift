//
//  TrackExitLinkAnalyticsPropertiesDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/22/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackExitLinkAnalyticsPropertiesDomainModel: Sendable {
    
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let appLanguage: String?
    let contentLanguage: String?
    let contentLanguageSecondary: String?
    let url: URL
}
