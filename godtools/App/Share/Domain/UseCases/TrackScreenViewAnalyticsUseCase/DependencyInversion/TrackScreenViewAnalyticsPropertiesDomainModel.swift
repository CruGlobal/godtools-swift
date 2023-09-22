//
//  TrackScreenViewAnalyticsPropertiesDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 9/21/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

struct TrackScreenViewAnalyticsPropertiesDomainModel {
    
    let previousScreenName: String
    let screenName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String?
    let contentLanguageSecondary: String?
    let data: [String: Any]?
}
