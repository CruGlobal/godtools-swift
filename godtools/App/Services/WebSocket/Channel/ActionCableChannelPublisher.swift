//
//  ActionCableChannelPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import Combine

class ActionCableChannelPublisher: NSObject, WebSocketChannelPublisherInterface {
    
    private let webSocket: WebSocketInterface
    private let didCreateChannelSubject: PassthroughSubject<WebSocketChannel, Never> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var cancellables: Set<AnyCancellable> = Set()
    private var channelToCreate: WebSocketChannel?
    private var publishingToSubscriberChannel: WebSocketChannel?
    private var appResignedActive: Bool = false
    
    private(set) var webSocketUrl: URL?
    private(set) var channel: WebSocketChannel?
    private(set) var publishChannel: WebSocketChannel?
        
    required init(webSocket: WebSocketInterface, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        webSocket
            .didReceiveTextPublisher
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        webSocket.disconnect()
    }
    
    var isSubscriberChannelCreatedForPublish: Bool {
        return publishingToSubscriberChannel != nil
    }
    
    var subscriberChannel: WebSocketChannel? {
        return publishingToSubscriberChannel
    }
    
    func createChannelPublisher(url: URL, channel: WebSocketChannel) -> AnyPublisher<WebSocketChannel, Never> {
        
        self.webSocketUrl = url
        self.channel = channel
        
        channelToCreate = channel
        
        if webSocket.connectionState != .connected && webSocket.connectionState != .connecting {
            
            webSocket.connectPublisher(url: url)
                .sink { [weak self] completion in
                    
                    switch completion {
                    case .finished:
                        self?.handleDidConnectToWebsocket()
                    case .failure(let error):
                        break
                    }
                    
                } receiveValue: { _ in
                    
                }
                .store(in: &cancellables)
        }
        else if webSocket.connectionState == .connected {
            
            handleDidConnectToWebsocket()
        }
        
        return didCreateChannelSubject
            .eraseToAnyPublisher()
    }
    
    func sendMessage(data: String) {
        
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
                                                
        webSocket.write(string: stringMessage)
    }
    
    private func handleDidConnectToWebsocket() {
               
        if loggingEnabled {
            print("\n ActionCableChannelPublisher: handleDidConnectToWebsocket()")
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
                webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleDidReceiveText(text: String) {
        
        if loggingEnabled {
            print("\n ActionCableChannelPublisher: handleDidReceiveText() \(text)")
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
        didCreateChannelSubject.send(subscriberChannel)
        didCreateChannelSubject.send(completion: .finished)
    }
}

extension ActionCableChannelPublisher {
    
    @objc private func appWillResignActive() {
        appResignedActive = true
        webSocket.disconnect()
    }
    
    @objc private func appDidBecomeActive() {
        
        guard appResignedActive else {
            return
        }
        
        appResignedActive = false
        
        guard let websocketUrl = self.webSocketUrl, let channel = self.channel else {
            return
        }
        
        _ = createChannelPublisher(url: websocketUrl, channel: channel)
    }
}
