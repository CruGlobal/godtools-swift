//
//  WebSocketChannelSubscriberInterface.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

protocol WebSocketChannelSubscriberInterface {
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool)
    
    var isSubscribedToChannel: Bool { get }
    
    func subscribePublisher(url: URL, channel: WebSocketChannel) -> AnyPublisher<WebSocketChannel, Never>
    func unsubscribe()
}
