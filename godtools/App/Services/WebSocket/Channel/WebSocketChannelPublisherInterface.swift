//
//  WebSocketChannelPublisherInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol WebSocketChannelPublisherInterface {
    
    var channel: WebSocketChannel? { get }
    var publishChannel: WebSocketChannel? { get }
    var subscriberChannel: WebSocketChannel? { get }
    var isSubscriberChannelIdCreatedForPublish: Bool { get }
    var didCreateChannelForPublish: SignalValue<String> { get }
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    func createChannelForPublish(url: URL, channelId: String)
    func sendMessage(data: String)
}
