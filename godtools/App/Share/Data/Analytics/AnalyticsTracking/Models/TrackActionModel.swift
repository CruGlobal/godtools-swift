//
//  TrackActionModel.swift
//  godtools
//
//  Created by Robert Eldredge on 6/3/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

struct TrackActionModel {

    let properties: AnalyticsProperties
    let actionName: String
    let url: String?
    let data: [String: Any]?
}
