//
//  WebSocketChannelPublisherType.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketChannelPublisherType {
    
    var channelId: String? { get }
    var subscriberChannelId: String? { get }
    var isSubscriberChannelIdCreatedForPublish: Bool { get }
    var didCreateChannelForPublish: SignalValue<String> { get }
    
    init(webSocket: WebSocketType, loggingEnabled: Bool)
    
    func createChannelForPublish(url: URL, channelId: String)
}
