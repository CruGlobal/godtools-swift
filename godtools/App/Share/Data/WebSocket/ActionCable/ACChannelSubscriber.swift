//
//  ACChannelSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

actor ACChannelSubscriber: ACChannelSubscriberInterface {
    
    static let timeoutIntervalSeconds: TimeInterval = ACChannelPublisher.timeoutIntervalSeconds
    
    private let webSocket: WebSocketInterface
    private let loggingEnabled: Bool
    private let subscribedStream: MultiBroadcastThrowingStream<WebSocketChannel> = MultiBroadcastThrowingStream()
    
    private var creatingChannel: WebSocketChannel?
    private var receiveTextTask: Task<Void, Never>?
    private var timeoutTask: TimeoutTask?
        
    private(set) var subscribedToChannel: WebSocketChannel?
    
    init(webSocket: WebSocketInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
                
        Task { [weak self] in
            
            guard let connectionStateStream: AsyncStream<WebSocketConnectionState> = await self?.webSocket.getConnectionStateStream() else {
                return
            }
            
            for await connectionState in connectionStateStream {
                
                await self?.handleConnectionStateChanged(connectionState: connectionState)
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func startTimeoutTask() {
        
        stopTimeoutTask()
        
        timeoutTask = TimeoutTask(timeoutIntervalSeconds: Self.timeoutIntervalSeconds) { [weak self] in
            await self?.handleDidTimeout()
        }
    }
    
    private func stopTimeoutTask() {
        
        timeoutTask?.cancel()
        timeoutTask = nil
    }
    
    private func handleDidTimeout() async {
        
        await unsubscribe(disconnectSocket: true)
        
        await subscribedStream.send(error: ACCreateChannelError.timedOut)
    }
    
    var isCreatingChannel: Bool {
        return creatingChannel != nil
    }
    
    var isSubscribedToChannel: Bool {
        return subscribedToChannel != nil
    }
    
    var connectionState: WebSocketConnectionState {
        get async {
            return await webSocket.connectionState
        }
    }
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState> {
        return await webSocket.getConnectionStateStream()
    }
    
    func getTextStream() async -> AsyncThrowingStream<String, Error> {
        return await webSocket.getTextStream()
    }
    
    func getSubscribedStream() async -> AsyncThrowingStream<WebSocketChannel, Error> {
        
        return await subscribedStream.getNewStream()
    }
    
    private func sendDidSubscribeToChannel(channel: WebSocketChannel) async {
        
        await subscribedStream.send(value: channel)
    }

    func subscribe(url: URL, channel: WebSocketChannel) async throws(ACCreateChannelError) {
        
        guard !isCreatingChannel else {
            throw .isCreatingChannel
        }
        
        guard !isSubscribedToChannel else {
            throw .channelAlreadyCreated
        }
        
        startTimeoutTask()
        
        creatingChannel = channel
        
        await webSocket.connect(url: url)
        
        await startObservingWebSocketText()
    }
    
    func unsubscribe(disconnectSocket: Bool) async {
        
        stopTimeoutTask()
        
        cancelReceiveTextTask()
        
        creatingChannel = nil
        subscribedToChannel = nil
        
        if disconnectSocket {
            await webSocket.disconnect()
        }
    }
    
    private func cancelReceiveTextTask() {
        
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func startObservingWebSocketText() async {
        
        let textStream = await webSocket.getTextStream()
        
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
    
    private func handleConnectionStateChanged(connectionState: WebSocketConnectionState) async {
                
        if loggingEnabled {
            print("\n ACChannelSubscriber: handleConnectionStateChanged()")
            print("  connectionState: \(connectionState)")
        }
        
        if connectionState.isConnected {
            
            await handleDidConnectToWebsocket()
        }
    }
    
    private func handleDidConnectToWebsocket() async {
              
        if loggingEnabled {
            print("\n ACChannelSubscriber: handleDidConnectToWebsocket()")
        }
        
        guard let creatingChannel = creatingChannel else {
            return
        }
                        
        let strChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(creatingChannel.id)\" }"
        let message = ["command": "subscribe", "identifier": strChannel]

        do {
            
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                await webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleDidReceiveText(text: String) async {
        
        if loggingEnabled {
            print("\n ACChannelSubscriber: handleDidReceiveText() \(text)")
        }
                
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        let event: ACEventCodable?
        
        do {
            event = try JSONDecoder().decode(ACEventCodable.self, from: data)
        }
        catch {
            event = nil
        }
        
        if event?.type == "welcome" {

        }
        else if event?.type == "confirm_subscription" {
            
            if let creatingChannel = creatingChannel {
                await handleDidSubscribeToChannel(channel: creatingChannel)
            }
        }
    }
    
    private func handleReceiveTextError(error: Error) {
        
        if loggingEnabled {
            print("\n ACChannelSubscriber: handleReceiveTextError() \(error)")
        }
    }
    
    private func handleDidSubscribeToChannel(channel: WebSocketChannel) async {
        
        stopTimeoutTask()
        
        creatingChannel = nil
        subscribedToChannel = channel
        
        await sendDidSubscribeToChannel(channel: channel)
    }
}
