//
//  ACChannelPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

actor ACChannelPublisher {
    
    private let webSocket: WebSocketInterface
    private let loggingEnabled: Bool
    
    private var createdChannelContinuations: [UUID: AsyncStream<WebSocketChannel>.Continuation] = Dictionary()
    private var channelToCreate: WebSocketChannel?
    private var publishingToSubscriberChannel: WebSocketChannel?
    private var receiveTextTask: Task<Void, Never>?
    private var appResignedActive: Bool = false
    
    private(set) var channel: WebSocketChannel?
    private(set) var publishChannel: WebSocketChannel?
        
    init(webSocket: WebSocketInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
                
        // TODO: Fix. ~Levi
        //NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
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
    
    var connectionState: WebSocketConnectionState {
        get async {
            return await webSocket.connectionState
        }
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        return publishingToSubscriberChannel != nil
    }
    
    var subscriberChannel: WebSocketChannel? {
        return publishingToSubscriberChannel
    }
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState> {
        return await webSocket.getConnectionStateStream()
    }
    
    func getCreatedChannelStream() -> AsyncStream<WebSocketChannel> {
        
        let (stream, continuation) = AsyncStream<WebSocketChannel>.makeStream()
        let continuationId: UUID = UUID()
        
        createdChannelContinuations[continuationId] = continuation
        
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeCreatedChannelContination(continuationId: continuationId) }
        }
                
        return stream
    }
    
    private func removeCreatedChannelContination(continuationId: UUID) {
        
        createdChannelContinuations[continuationId] = nil
    }
    
    private func sendCreatedChannel(channel: WebSocketChannel) {
        for continuation in createdChannelContinuations.values {
            continuation.yield(channel)
        }
    }
    
    func sendMessage(data: String) async {
        
        let stringMessage: String
            
        do {
            
            let message: [String: Any] = [
                "identifier": publishChannel?.id ?? "",
                "data": data,
                "command": "message"
            ]
            
            let messageData: Data = try JSONSerialization.data(withJSONObject: message)
            stringMessage = String(data: messageData, encoding: .utf8) ?? ""
        }
        catch {
            stringMessage = ""
        }
                                                
        await webSocket.write(string: stringMessage)
    }
    
    func createChannel(url: URL, channel: WebSocketChannel) async throws {
        
        let connectionState: WebSocketConnectionState = await webSocket.connectionState
        
        guard !connectionState.isConnected && !connectionState.isConnecting else {
            // TODO: Should throw error that websocket is connected or connecting. ~Levi
            return
        }
        
        self.channel = channel
        
        channelToCreate = channel
        
        await webSocket.connect(url: url)
        
        try await startObservingWebSocketText()
    }
    
    func disconnect() async {
        cancelReceiveTextTask()
        await webSocket.disconnect()
    }
    
    private func cancelReceiveTextTask() {
        
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func startObservingWebSocketText() async throws {
        
        let textStream = try await webSocket.getReceiveTextStream()
        
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
    
    private func handleConnectionStateChanged(connectionState: WebSocketConnectionState) async {
                
        if loggingEnabled {
            print("\n ACChannelPublisher: handleConnectionStateChanged()")
            print("  connectionState: \(connectionState)")
        }
        
        if connectionState.isConnected {
            
            await handleDidConnectToWebsocket()
        }
        
        // TODO: Handle disconnected. ~Levi
    }
    
    private func handleDidConnectToWebsocket() async {
               
        if loggingEnabled {
            print("\n ACChannelPublisher: handleDidConnectToWebsocket()")
        }
        
        guard let channel = channelToCreate else {
            return
        }
                        
        let stringChannel: String = "{ \"channel\": \"PublishChannel\",\"channelId\": \"\(channel.id)\" }"
        let message: [String: Any] = ["command": "subscribe", "identifier": stringChannel]
        
        publishChannel = WebSocketChannel(id: stringChannel)
        
        do {
            
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                await webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleDidReceiveText(text: String) {
        
        if loggingEnabled {
            print("\n ACChannelPublisher: handleDidReceiveText() \(text)")
            print("  channelIdToCreate: \(String(describing: channelToCreate?.id))")
        }
        
        guard let data = text.data(using: .utf8) else {
            return
        }
        
        let jsonObject: [String: Any]
        
        do {
            
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            jsonObject = json as? [String: Any] ?? Dictionary()
        }
        catch {
            jsonObject = Dictionary()
        }
               
        let jsonData: [String: Any]? = (jsonObject["message"] as? [String: Any])?["data"] as? [String: Any]
                
        if let jsonData = jsonData,
           let type = jsonData["type"] as? String,
           type == "publisher-info",
           let subscriberChannelId = (jsonData["attributes"] as? [String: Any])?["subscriberChannelId"] as? String,
           let subscriberChannel = WebSocketChannel(id: subscriberChannelId) {
            
            if loggingEnabled {
                print("  channelIdToCreate: \(String(describing: channelToCreate?.id))")
                print("  subscriberChannelId: \(subscriberChannelId)")
            }
            
            handleDidCreateSubscriberChannel(subscriberChannel: subscriberChannel)
        }
    }
    
    private func handleDidCreateSubscriberChannel(subscriberChannel: WebSocketChannel) {
                
        channelToCreate = nil
        
        publishingToSubscriberChannel = subscriberChannel
        
        sendCreatedChannel(channel: subscriberChannel)
    }
    
    // TODO: Fix. ~Levi
    
    /*
    @objc private func appWillResignActive() {
        
        appResignedActive = true
        
        Task {
            await webSocket.disconnect()
        }
    }
    
    @objc private func appDidBecomeActive() {
        
        guard appResignedActive else {
            return
        }
        
        appResignedActive = false
        
        guard let channel = self.channel else {
            return
        }
        
        Task {
            await createChannel(channel: channel)
        }
    }*/
}
