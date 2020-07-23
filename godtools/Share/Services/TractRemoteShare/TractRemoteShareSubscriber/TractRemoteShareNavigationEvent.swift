//
//  TractRemoteShareNavigationEvent.swift
//  godtools
//
//  Created by Levi Eggert on 7/20/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct TractRemoteShareNavigationEvent: Codable {
    
    var card: Int?
    var locale: String?
    var page: Int?
    var tool: String?
    
    enum RootKeys: String, CodingKey {
        
        case card = "card"
        case locale = "locale"
        case page = "page"
        case tool = "tool"
    }
}
