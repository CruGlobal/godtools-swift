//
//  SnowplowAnalyticsProperties.swift
//  godtools
//
//  Created by Robert Eldredge on 5/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import TheKeyOAuthSwift

struct SnowplowAnalyticsProperties: Encodable {
    
    var appName: String?
    var grMasterPersonID: String?
    var marketingCloudID: String?
    var ssoguid: String?
    
    enum CodingKeys: String, CodingKey {
        
        case appName = "cru.appname"
        case grMasterPersonID = "cru.grmpid"
        case marketingCloudID = "cru.mcid"
        case ssoguid = "cru.ssoguid"
    }
}
