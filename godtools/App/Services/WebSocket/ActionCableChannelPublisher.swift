//
//  ActionCableChannelPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ActionCableChannelPublisher: NSObject, WebSocketChannelPublisherType {
    
    private let webSocket: WebSocketType
    private let loggingEnabled: Bool
    
    private var channelIdToCreate: String?
    private var publishingToSubscriberChannelId: String?
    private var isObservingTextSignal: Bool = false
    private var appResignedActive: Bool = false
    
    private(set) var websocketUrl: URL?
    private(set) var channelId: String?
    private(set) var publishChannelIdentifier: String?
    
    let didCreateChannelForPublish: SignalValue<String> = SignalValue()
    
    required init(webSocket: WebSocketType, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        
        webSocket.didConnectSignal.removeObserver(self)
        removeTextSignalObserver()
        webSocket.disconnect()
    }
    
    var isSubscriberChannelIdCreatedForPublish: Bool {
        return publishingToSubscriberChannelId != nil
    }
    
    var subscriberChannelId: String? {
        return publishingToSubscriberChannelId
    }
    
    func createChannelForPublish(url: URL, channelId: String) {
                
        removeTextSignalObserver()
        
        self.websocketUrl = url
        self.channelId = channelId
        
        channelIdToCreate = channelId
        
        if !webSocket.isConnected {
            
            webSocket.didConnectSignal.addObserver(self) { [weak self] in
                
                guard let channelPublisher = self else {
                    return
                }
                channelPublisher.webSocket.didConnectSignal.removeObserver(channelPublisher)
                channelPublisher.handleDidConnectToWebsocket()
            }
            
            webSocket.connect(url: url)
        }
        else {
            
            handleDidConnectToWebsocket()
        }
    }
    
    func sendMessage(data: String) {
        
        let stringMessage: String
            
        do {
            
            let message: [String: Any] = [
                "identifier": publishChannelIdentifier ?? "",
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
    
    private func addTextSignalObserver() {
        if !isObservingTextSignal {
            isObservingTextSignal = true
            webSocket.didReceiveTextSignal.addObserver(self) { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            }
        }
    }
    
    private func removeTextSignalObserver() {
        if isObservingTextSignal {
            isObservingTextSignal = false
            webSocket.didReceiveTextSignal.removeObserver(self)
        }
    }
    
    private func handleDidConnectToWebsocket() {
               
        if loggingEnabled {
            print("\n ActionCableChannelPublisher: handleDidConnectToWebsocket()")
        }
        
        guard let channelId = channelIdToCreate else {
            return
        }
        
        addTextSignalObserver()
                
        let stringChannel = "{ \"channel\": \"PublishChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command" : "subscribe", "identifier": stringChannel]
        
        publishChannelIdentifier = stringChannel

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
            print("  channelIdToCreate: \(String(describing: channelIdToCreate))")
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
                
        if let jsonData = jsonData, let type = jsonData["type"] as? String {
                
            if type == "publisher-info", let subscriberChannelId = (jsonData["attributes"] as? [String: Any])?["subscriberChannelId"] as? String {
                                
                if loggingEnabled {
                    print("  channelIdToCreate: \(String(describing: channelIdToCreate))")
                    print("  subscriberChannelId: \(subscriberChannelId)")
                }
                
                handleDidCreateSubscriberChannelId(subscriberChannelId: subscriberChannelId)
            }
        }
    }
    
    private func handleDidCreateSubscriberChannelId(subscriberChannelId: String) {
        
        channelIdToCreate = nil
        publishingToSubscriberChannelId = subscriberChannelId
        didCreateChannelForPublish.accept(value: subscriberChannelId)
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
        
        guard let websocketUrl = self.websocketUrl, let channelId = self.channelId else {
            return
        }
        
        createChannelForPublish(url: websocketUrl, channelId: channelId)
    }
}
