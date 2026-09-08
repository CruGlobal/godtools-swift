//
//  ACChannelSubscriberInterface.swift
//  godtools
//
//  Created by Levi Eggert on 8/19/26.
//  Copyright © 2026 Cru. All rights reserved.
//

import Foundation

protocol ACChannelSubscriberInterface: Actor {
    
    var subscribedToChannel: WebSocketChannel? { get }
    var isCreatingChannel: Bool { get }
    var isSubscribedToChannel: Bool { get }
    var connectionState: WebSocketConnectionState { get async }
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState>
    func getTextStream() async -> AsyncThrowingStream<String, Error>
    func getSubscribedStream() async -> AsyncThrowingStream<WebSocketChannel, Error>
    func subscribe(url: URL, channel: WebSocketChannel) async throws(ACCreateChannelError)
    func unsubscribe(disconnectSocket: Bool) async
}
