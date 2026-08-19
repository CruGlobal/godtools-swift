//
//  ACChannelPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import UIKit

actor ACChannelPublisher: ACChannelPublisherInterface {
    
    private let webSocket: WebSocketInterface
    private let loggingEnabled: Bool
    private let createdChannelStream: MultiBroadcastStream<WebSocketChannel> = MultiBroadcastStream()
    
    private var createChannel: WebSocketChannel?
    private var receiveTextTask: Task<Void, Never>?
    
    private(set) var publishChannel: WebSocketChannel?
    private(set) var subscriberChannel: WebSocketChannel?
        
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
    
    var isCreatingChannel: Bool {
        return createChannel != nil
    }
    
    var subscriberChannelCreated: Bool {
        return subscriberChannel != nil
    }
    
    var connectionState: WebSocketConnectionState {
        get async {
            return await webSocket.connectionState
        }
    }
    
    func getConnectionStateStream() async -> AsyncStream<WebSocketConnectionState> {
        return await webSocket.getConnectionStateStream()
    }
    
    func getCreatedChannelStream() async -> AsyncStream<WebSocketChannel> {
        
        return await createdChannelStream.getNewStream(sendValue: subscriberChannel)
    }
    
    func createChannel(url: URL, channel: WebSocketChannel) async throws(ACCreateChannelError) {
        
        guard !isCreatingChannel else {
            throw .isCreatingChannel
        }
        
        guard !subscriberChannelCreated else {
            throw .channelAlreadyCreated
        }
        
        self.createChannel = channel
                
        await webSocket.connect(url: url)
        
        await startObservingWebSocketText()
    }
    
    func closeChannel(disconnectSocket: Bool) async {
        
        cancelReceiveTextTask()
        
        self.createChannel = nil
        self.publishChannel = nil
        self.subscriberChannel = nil
        
        if disconnectSocket {
            await webSocket.disconnect()
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
            print("\n ACChannelPublisher: handleConnectionStateChanged()")
            print("  connectionState: \(connectionState)")
        }
        
        if connectionState.isConnected {
            
            await handleDidConnectToWebsocket()
        }
    }
    
    private func handleDidConnectToWebsocket() async {
               
        if loggingEnabled {
            print("\n ACChannelPublisher: handleDidConnectToWebsocket()")
        }
        
        guard let createChannel = self.createChannel else {
            return
        }
                        
        let stringChannel: String = "{ \"channel\": \"PublishChannel\",\"channelId\": \"\(createChannel.id)\" }"
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
    
    private func handleDidReceiveText(text: String) async {
        
        if loggingEnabled {
            print("\n ACChannelPublisher: handleDidReceiveText() \(text)")
            print("  channelIdToCreate: \(String(describing: createChannel?.id))")
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
                print("  channelIdToCreate: \(String(describing: createChannel?.id))")
                print("  subscriberChannelId: \(subscriberChannelId)")
            }
            
            await handleDidCreateSubscriberChannel(subscriberChannel: subscriberChannel)
        }
    }
    
    private func handleReceiveTextError(error: Error) {
        
        if loggingEnabled {
            print("\n ACChannelPublisher: handleReceiveTextError() \(error)")
        }
    }
    
    private func handleDidCreateSubscriberChannel(subscriberChannel: WebSocketChannel) async {
                      
        cancelReceiveTextTask()
        
        createChannel = nil
        
        self.subscriberChannel = subscriberChannel
        
        await sendCreatedChannel(channel: subscriberChannel)
    }
    
    private func sendCreatedChannel(channel: WebSocketChannel) async {
        
        await createdChannelStream.send(value: channel)
    }
}
