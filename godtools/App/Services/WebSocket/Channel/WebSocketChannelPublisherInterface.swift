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
    
    var didCreateChannelPublisher: AnyPublisher<WebSocketChannel, Never> { get }
    var channel: WebSocketChannel? { get }
    var publishChannel: WebSocketChannel? { get }
    var subscriberChannel: WebSocketChannel? { get }
    var isSubscriberChannelCreatedForPublish: Bool { get }
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    func createChannel(channel: WebSocketChannel)
    func sendMessage(data: String)
}
