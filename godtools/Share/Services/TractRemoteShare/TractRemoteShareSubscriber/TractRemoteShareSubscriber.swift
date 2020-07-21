//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Starscream

class TractRemoteShareSubscriber {
        
    private let socket: WebSocket
    private let jsonServices: JsonServices = JsonServices()
    
    private var subscribeToChannel: String?
    private var isConnected: Bool = false
        
    let navigationEventSignal: SignalValue<TractRemoteShareNavigationEvent> = SignalValue()
    
    required init(config: ConfigType) {
        
        let remoteUrl: URL? = URL(string: config.mobileContentApiBaseUrl + "/" + "cable")
        
        socket = WebSocket(request: URLRequest(url: remoteUrl!))
        socket.onEvent = { [weak self] event in
            self?.handleWebSocketEvent(event: event)
        }
    }
    
    deinit {
        
        //unsubscribeCurrentChannel()
        //disconnectClient()
    }
    
    private func handleWebSocketEvent(event: WebSocketEvent) {
        
        print("\n TractRemoteShareSubscriber: handleWebSocketEvent() event: \(event)")
        
        switch event {
        
        case .connected(let headers):
            
            isConnected = true
            handleSocketConnected()
            print("websocket is connected: \(headers)")
        
        case .disconnected(let reason, let code):
            
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        
        case .text(let string):
            
            let data: Data? = string.data(using: .utf8)
            let jsonObject: Any? = jsonServices.getJsonObject(data: data)
            handleReceivedMessage(json: jsonObject)
        
        case .binary( _):
            break
        
        case .ping(_):
            break
        
        case .pong(_):
            break
        
        case .viabilityChanged(_):
            break
        
        case .reconnectSuggested(_):
            break
        
        case .cancelled:
            isConnected = false
        
        case .error(let error):
            isConnected = false
            print("\n TractRemoteShareSubscriber: handleWebSocketEvent() Error: \(String(describing: error))")
        }
    }
    
    private func handleSocketConnected() {
        
        print("\n WebSocket Connected - subscribe to channel.")
        
        guard let channelId = subscribeToChannel else {
            return
        }
        
        let strChannel = "{ \"channel\": \"SubscribeChannel\",\"channelId\": \"\(channelId)\" }"
        let message = ["command" : "subscribe","identifier": strChannel]

        do {
            let data = try JSONSerialization.data(withJSONObject: message)
            if let dataString = String(data: data, encoding: .utf8){
                socket.write(string: dataString)
            }
            
        } catch let error {

        }
    }
    
    func subscribeToChannel(liveShareStream: String) {
               
        subscribeToChannel = liveShareStream
        
        if !isConnected {
            socket.connect()
        }
        else {
            handleSocketConnected()
        }
    }
    
    func unsubscribeChannel() {
        
        subscribeToChannel = nil
        socket.disconnect()
    }
    
    private func handleReceivedMessage(json: Any?) {
        
        print("\n TractRemoteShareSubscriber: handleReceivedMessage()")
        
        guard let jsonObject = json as? [String: Any] else {
            return
        }
        
        if let type = jsonObject["type"] as? String {
            print("  TYPE: \(type)")
            
            if type == "welcome" {
                // sent when subscribing to a channel
            }
            else if type == "confirm_subscription" {
                // sent when subscribing to a channel
            }
        }
        else if let messageObject = jsonObject["message"] as? [String: Any], let dataObject = messageObject["data"] as? [String: Any] {
            
            guard let eventType = dataObject["type"] as? String, let attributes = dataObject["attributes"] as? [String: Any] else {
                return
            }
                        
            let attributesData: Data? = jsonServices.getJsonData(json: attributes)
            
            if eventType == "navigation-event" {
                
                let navigationEvent: TractRemoteShareNavigationEvent? = jsonServices.decodeObject(data: attributesData)
                
                if let event = navigationEvent {
                    navigationEventSignal.accept(value: event)
                }
                
                print("  navigationEvent.page: \(String(describing: navigationEvent?.page))")
                print("  navigationEvent.card: \(String(describing: navigationEvent?.card))")
                print("  navigationEvent.locale: \(String(describing: navigationEvent?.locale))")
                print("  navigationEvent.tool: \(String(describing: navigationEvent?.tool))")
            }
        }
    }
}
