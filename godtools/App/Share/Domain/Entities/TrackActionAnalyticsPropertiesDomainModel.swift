//
//  TrackActionAnalyticsPropertiesDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackActionAnalyticsPropertiesDomainModel {
    
    let screenName: String
    let actionName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String?
    let contentLanguageSecondary: String?
    let url: String?
    let data: [String: Any]?
}
