//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor TractRemoteShareSubscriber {
                
    private let navigationEventStream: MultiBroadcastStream<TractRemoteShareNavigationEvent> = MultiBroadcastStream()
    private let connectionUrl: String
    private let channelSubscriber: ACChannelSubscriberInterface
    private let loggingEnabled: Bool
    
    private var receiveTextTask: Task<Void, Never>?
    
    init(
        connectionUrl: String,
        channelSubscriber: ACChannelSubscriberInterface,
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
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState> {
        
        return await channelSubscriber.getConnectionStateStream()
    }
    
    func getSubscribedStream() async -> AsyncThrowingStream<WebSocketChannel, Error> {
        
        return await channelSubscriber.getSubscribedStream()
    }
    
    func getNavigationEventStream() async -> AsyncStream<TractRemoteShareNavigationEvent> {
        
        return await navigationEventStream.getNewStream(bufferingPolicy: .bufferingNewest(1))
    }
    
    private func sendNavigationEvent(event: TractRemoteShareNavigationEvent) async {
        
        await navigationEventStream.send(value: event)
    }
    
    private func cancelReceiveTextTask() {
        
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func startObservingWebSocketText() async {
        
        let textStream = await channelSubscriber.getTextStream()
        
        cancelReceiveTextTask()
        
        receiveTextTask = Task { [weak self] in

            do {
                
                for try await text in textStream {
                    
                    await self?.handleDidReceiveText(text: text)
                }
            }
            catch let error {
                
                await self?.handleReceiveTextError(error: error)
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
                
        try await channelSubscriber.subscribe(url: url, channel: channel)
        
        await startObservingWebSocketText()
    }
    
    func unsubscribe(disconnectSocket: Bool) async {
                        
        cancelReceiveTextTask()
                
        await channelSubscriber.unsubscribe(disconnectSocket: disconnectSocket)
    }
    
    private func handleReceiveTextError(error: Error) {
        
        log(method: "handleReceiveTextError()", label: "error", labelValue: error.localizedDescription)
    }
    
    private func handleDidReceiveText(text: String) async {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        guard let data = data else {
            return
        }
        
        do {
            
            let object: TractRemoteShareNavigationEvent = try JsonServices().decodeObject(data: data)
            
            if object.message?.data?.type == TractRemoteShareNavigationEvent.type {
                await sendNavigationEvent(event: object)
            }
        }
        catch _ {
            
        }
    }
}
