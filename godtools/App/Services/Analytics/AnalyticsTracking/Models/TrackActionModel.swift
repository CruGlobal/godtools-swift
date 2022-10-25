//
//  TrackActionModel.swift
//  godtools
//
//  Created by Robert Eldredge on 6/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct TrackActionModel {
    
    let screenName: String
    let actionName: String
    let siteSection: String
    let siteSubSection: String
    let contentLanguage: String?
    let secondaryContentLanguage: String?
    let url: String?
    let data: [String: Any]?
}
