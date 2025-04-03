//
//  WebSocketChannelPublisherInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

protocol WebSocketChannelPublisherInterface {
    
    var channel: WebSocketChannel? { get }
    var publishChannel: WebSocketChannel? { get }
    var subscriberChannel: WebSocketChannel? { get }
    var isSubscriberChannelCreatedForPublish: Bool { get }
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    func createChannelPublisher(url: URL, channel: WebSocketChannel) -> AnyPublisher<WebSocketChannel, Never>
    func sendMessage(data: String)
}
