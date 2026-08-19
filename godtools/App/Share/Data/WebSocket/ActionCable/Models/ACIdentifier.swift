//
//  ACIdentifier.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

struct ACIdentifier: Codable {
    
    let channel: String
    let channelId: String
    
    enum RootKeys: String, CodingKey {
        
        case channel = "channel"
        case channelId = "channelId"
    }
}
