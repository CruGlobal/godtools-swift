//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor TractRemoteShareSubscriber {
            
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let connectionUrl: String
    private let channelSubscriber: ACChannelSubscriber
    private let loggingEnabled: Bool
    
    private var navigationEventContinuation: [UUID: AsyncStream<TractRemoteShareNavigationEvent>.Continuation] = Dictionary()
    private var receiveTextTask: Task<Void, Never>?
    private var isSubscribingToChannel: WebSocketChannel?
    
    init(
        connectionUrl: String,
        channelSubscriber: ACChannelSubscriber,
        loggingEnabled: Bool
    ) {
        
        self.connectionUrl = connectionUrl
        self.channelSubscriber = channelSubscriber
        self.loggingEnabled = loggingEnabled
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteShareSubscriber \(method)")
            if let label = label, let labelValue = labelValue {
                print("  \(label): \(labelValue)")
            }
        }
    }
    
    var connectionState: WebSocketConnectionState {
        get async {
            return await channelSubscriber.connectionState
        }
    }
    
    var isSubscribedToChannel: Bool {
        get async {
            return await channelSubscriber.isSubscribedToChannel
        }
    }
    
    func getSubscribedStream() async -> AsyncStream<WebSocketChannel> {
        
        return await channelSubscriber.getSubscribedStream()
    }
    
    func getNavigationEventStream() -> AsyncStream<TractRemoteShareNavigationEvent> {
        
        let (stream, continuation) = AsyncStream<TractRemoteShareNavigationEvent>.makeStream()
        let continuationId: UUID = UUID()
        
        navigationEventContinuation[continuationId] = continuation
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeNavigationEventContinuation(continuationId: continuationId) }
        }
        
        return stream
    }
    
    private func removeNavigationEventContinuation(continuationId: UUID) {
        
        navigationEventContinuation[continuationId] = nil
    }
    
    private func sendNavigationEvent(event: TractRemoteShareNavigationEvent) {
        for continuation in navigationEventContinuation.values {
            continuation.yield(event)
        }
    }
    
    private func cancelReceiveTextTask() {
        
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func startObservingWebSocketText() async throws {
        
        let textStream = try await channelSubscriber.getReceiveTextStream()
        
        cancelReceiveTextTask()
        
        receiveTextTask = Task { [weak self] in

            do {

                for try await text in textStream {
                    
                    await self?.handleDidReceiveText(text: text)
                }
            }
            catch {

            }
        }
    }
    
    func subscribe(channel: WebSocketChannel) async throws {
            
        guard let url = URL(string: connectionUrl) else {
            
            throw NSError.errorWithDomain(
                domain: "TractRemoteShareSubscriber",
                code: -1,
                description: "Failed to create connection url with string: \(connectionUrl)"
            )
        }
        
        log(method: "subscribe()", label: "channelId", labelValue: channel.id)
                
        await unsubscribe(disconnectSocket: false)
        
        isSubscribingToChannel = channel
        
        try await channelSubscriber.subscribe(url: url, channel: channel)
    }
    
    func unsubscribe(disconnectSocket: Bool) async {
                
        isSubscribingToChannel = nil
        
        cancelReceiveTextTask()
                
        await channelSubscriber.unsubscribe(disconnectSocket: disconnectSocket)
    }
    
    private func handleDidReceiveText(text: String) {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        guard let data = data else {
            return
        }
        
        do {
            
            let object: TractRemoteShareNavigationEvent = try JsonServices().decodeObject(data: data)
            
            if object.message?.data?.type == "navigation-event" {
                sendNavigationEvent(event: object)
            }
        }
        catch _ {
            
        }
    }
}
