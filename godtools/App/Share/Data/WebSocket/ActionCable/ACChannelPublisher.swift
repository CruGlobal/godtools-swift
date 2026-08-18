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
    
    private let webSocket: URLSessionWebSocket
    private let loggingEnabled: Bool
    
    private var channelToCreate: WebSocketChannel?
    private var publishingToSubscriberChannel: WebSocketChannel?
    private var receiveTextTask: Task<Void, Never>?
    private var appResignedActive: Bool = false
    
    private(set) var channel: WebSocketChannel?
    private(set) var publishChannel: WebSocketChannel?
        
    init(webSocket: URLSessionWebSocket, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
                
        // TODO: Fix. ~Levi
        //NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        // TODO: Fix. ~Levi
        //NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        //NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // TODO: Fix. ~Levi
        //webSocket.disconnect()
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        return publishingToSubscriberChannel != nil
    }
    
    var subscriberChannel: WebSocketChannel? {
        return publishingToSubscriberChannel
    }
    
    private func cancelReceiveTextTask() {
        
        receiveTextTask?.cancel()
        receiveTextTask = nil
    }
    
    private func startObservingText() async {
        
        guard let textStream = await webSocket.getReceiveTextStream() else {
            return
        }
        
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
    
    func createChannel(url: URL, channel: WebSocketChannel) async {
        
        self.channel = channel
        
        channelToCreate = channel
        
        let connectionState: WebSocketConnectionState = await webSocket.connectionState
        
        if connectionState != .connected && connectionState != .connecting {
                        
            await webSocket.connect(url: url)
            
            await startObservingText()
            
            await handleDidConnectToWebsocket()
        }
        else if connectionState == .connected {
            
            await handleDidConnectToWebsocket()
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
        
        // TODO: Fix. ~Levi
        //didCreateChannelSubject.send(subscriberChannel)
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
