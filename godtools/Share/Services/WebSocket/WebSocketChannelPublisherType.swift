//
//  WebSocketChannelPublisherType.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketChannelPublisherType {
    
    init(webSocket: WebSocketType, loggingEnabled: Bool)
    
    func createChannelForPublish(url: URL, channelId: String)
}
