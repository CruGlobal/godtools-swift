//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class TractRemoteShareSubscriber: NSObject {
            
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let remoteUrl: URL
    private let webSocket: WebSocketInterface
    private let webSocketChannelSubscriber: WebSocketChannelSubscriberInterface
    private let navigationEventSubject: PassthroughSubject<TractRemoteShareNavigationEvent, Never> = PassthroughSubject()
    private let loggingEnabled: Bool
    
    private var didSubscribeToChannelSubject: PassthroughSubject<WebSocketChannel, TractRemoteShareSubscriberError>?
    private var cancellables: Set<AnyCancellable> = Set()
    private var timeoutTimer: Timer?
    private var isSubscribingToChannel: WebSocketChannel?
    
    required init(config: AppConfig, webSocket: WebSocketInterface, webSocketChannelSubscriber: WebSocketChannelSubscriberInterface, loggingEnabled: Bool) {
        
        // TODO: Shouldn't force unwrap here. ~Levi
        self.remoteUrl = URL(string: config.getTractRemoteShareConnectionUrl())!
        self.webSocket = webSocket
        self.webSocketChannelSubscriber = webSocketChannelSubscriber
        self.loggingEnabled = loggingEnabled
        
        super.init()
        
        webSocket
            .didReceiveTextPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            })
            .store(in: &cancellables)
    }
    
    deinit {
        unsubscribe(disconnectSocket: true)
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
        
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteShareSubscriber \(method)")
            if let label = label, let labelValue = labelValue {
                print("  \(label): \(labelValue)")
            }
        }
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.connectionState == .connected
    }
    
    var isSubscribedToChannel: Bool {
        return webSocketChannelSubscriber.isSubscribedToChannel
    }
    
    var navigationEventPublisher: AnyPublisher<TractRemoteShareNavigationEvent, Never> {
        return navigationEventSubject
            .eraseToAnyPublisher()
    }
    
    func subscribePublisher(channel: WebSocketChannel) -> AnyPublisher<WebSocketChannel, TractRemoteShareSubscriberError> {
            
        log(method: "subscribe()", label: "channelId", labelValue: channel.id)
                
        if channel == isSubscribingToChannel, let didSubscribeToChannelSubject = self.didSubscribeToChannelSubject {
            
            return didSubscribeToChannelSubject
                .eraseToAnyPublisher()
        }
        else if isSubscribingToChannel != nil && channel != isSubscribingToChannel {
            
            unsubscribe(disconnectSocket: false)
        }
        
        isSubscribingToChannel = channel
                
        let didSubscribeToChannelSubject: PassthroughSubject<WebSocketChannel, TractRemoteShareSubscriberError> = PassthroughSubject()
        
        self.didSubscribeToChannelSubject = didSubscribeToChannelSubject
        
        timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.timeoutIntervalSeconds, repeats: false) { [weak self] _ in
            
            self?.stopTimeoutTimer()
            
            didSubscribeToChannelSubject.send(completion: .failure(.timedOut))
        }
        
        webSocketChannelSubscriber
            .subscribePublisher(url: remoteUrl, channel: channel)
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.stopTimeoutTimer()
                
                didSubscribeToChannelSubject.send(channel)
                didSubscribeToChannelSubject.send(completion: .finished)
            }
            .store(in: &cancellables)
        
        return didSubscribeToChannelSubject
            .eraseToAnyPublisher()
    }
    
    func unsubscribe(disconnectSocket: Bool) {
        
        stopTimeoutTimer()
        
        isSubscribingToChannel = nil
        
        didSubscribeToChannelSubject = nil
        
        webSocketChannelSubscriber.unsubscribe()
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
}

// MARK: - Events

extension TractRemoteShareSubscriber {
    
    private func handleDidReceiveText(text: String) {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        let object: TractRemoteShareNavigationEvent? = JsonServices().decodeObject(data: data)
                
        if let object = object, object.message?.data?.type == "navigation-event" {
            
            navigationEventSubject.send(object)
        }
    }
}
