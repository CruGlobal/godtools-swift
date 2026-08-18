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
    
    private let channelSubscriber: ACChannelSubscriber
    private let loggingEnabled: Bool
    
    private var isSubscribingToChannel: WebSocketChannel?
    
    init(
        channelSubscriber: ACChannelSubscriber,
        loggingEnabled: Bool
    ) {
        
        self.channelSubscriber = channelSubscriber
        self.loggingEnabled = loggingEnabled
        
        // TODO: Fix. ~Levi
                
        /*
        webSocket
            .didReceiveTextPublisher
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)
        
         channelSubscriber
            .didSubscribePublisher
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                
                self?.didSubscribeSubject.send(channel)
            }
            .store(in: &cancellables)*/
    }
    
    deinit {
        
        // TODO: Fix. ~Levi
        //unsubscribe(disconnectSocket: true)
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
    
    func subscribe(channel: WebSocketChannel) async {
            
        log(method: "subscribe()", label: "channelId", labelValue: channel.id)
                
        await unsubscribe(disconnectSocket: false)
        
        isSubscribingToChannel = channel
        
        await channelSubscriber.subscribe(channel: channel)
    }
    
    func unsubscribe(disconnectSocket: Bool) async {
                
        isSubscribingToChannel = nil
                
        await channelSubscriber.unsubscribe(disconnectSocket: disconnectSocket)
    }
}

// MARK: - Events

extension TractRemoteShareSubscriber {
    
    private func handleDidReceiveText(text: String) {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        guard let data = data else {
            return
        }
        
        do {
            
            let object: TractRemoteShareNavigationEvent = try JsonServices().decodeObject(data: data)
            
            if object.message?.data?.type == "navigation-event" {
                
                // TODO: Fix. ~Levi
                //navigationEventSubject.send(object)
            }
        }
        catch _ {
            
        }
    }
}
