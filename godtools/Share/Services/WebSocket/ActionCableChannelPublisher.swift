//
//  ActionCableChannelPublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ActionCableChannelPublisher: NSObject, WebSocketChannelPublisherType {
    
    private let webSocket: WebSocketType
    private let loggingEnabled: Bool
    
    private var channelIdToCreate: String?
    private var isObservingJsonSignal: Bool = false
    
    let didCreateChannelForPublish: SignalValue<String> = SignalValue()
    
    required init(webSocket: WebSocketType, loggingEnabled: Bool) {
        
        self.webSocket = webSocket
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        webSocket.didConnectSignal.removeObserver(self)
        removeJsonSignalObserver()
        webSocket.disconnect()
    }
    
    func createChannelForPublish(url: URL, channelId: String) {
                
        removeJsonSignalObserver()
        
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
    
    private func addJsonSignalObserver() {
        if !isObservingJsonSignal {
            isObservingJsonSignal = true
            webSocket.didReceiveJsonSignal.addObserver(self) { [weak self] (json: [String: Any]) in
                self?.handleDidReceiveJson(json: json)
            }
        }
    }
    
    private func removeJsonSignalObserver() {
        if isObservingJsonSignal {
            isObservingJsonSignal = false
            webSocket.didReceiveJsonSignal.removeObserver(self)
        }
    }
    
    private func handleDidConnectToWebsocket() {
               
        if loggingEnabled {
            print("\n ActionCableChannelPublisher: handleDidConnectToWebsocket()")
        }
        
        guard let channelId = channelIdToCreate else {
            return
        }
        
        addJsonSignalObserver()
                
        let strChannel = "{ \"channel\": \"PublishChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command" : "subscribe", "identifier": strChannel]

        do {
            
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                webSocket.write(string: dataString)
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    private func handleDidReceiveJson(json: [String: Any]) {
        
        if loggingEnabled {
            print("\n ActionCableChannelPublisher: handleDidReceiveJson() \(json)")
            print("  channelIdToCreate: \(String(describing: channelIdToCreate))")
        }
                        
        let data: [String: Any]? = (json["message"] as? [String: Any])?["data"] as? [String: Any]
                
        if let data = data, let type = data["type"] as? String {
                
            if type == "publisher-info", let subscriberChannelId = (data["attributes"] as? [String: Any])?["subscriberChannelId"] as? String {
                                
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
        didCreateChannelForPublish.accept(value: subscriberChannelId)
    }
}
