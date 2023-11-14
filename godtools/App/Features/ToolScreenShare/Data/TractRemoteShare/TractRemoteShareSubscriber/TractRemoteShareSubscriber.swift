//
//  TractRemoteShareSubscriber.swift
//  godtools
//
//  Created by Levi Eggert on 7/18/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractRemoteShareSubscriber: NSObject {
            
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let remoteUrl: URL
    private let webSocket: WebSocketType
    private let webSocketChannelSubscriber: WebSocketChannelSubscriberType
    private let jsonServices: JsonServices = JsonServices()
    private let loggingEnabled: Bool
    
    private var timeoutTimer: Timer?
    private var didSubscribeToChannelClosure: ((_ error: TractRemoteShareSubscriberError?) -> Void)?
    private var isObservingSignals: Bool = false
        
    let navigationEventSignal: SignalValue<TractRemoteShareNavigationEvent> = SignalValue()
    let subscribedToChannelObserver: ObservableValue<Bool> = ObservableValue(value: false)
    
    required init(config: AppConfig, webSocket: WebSocketType, webSocketChannelSubscriber: WebSocketChannelSubscriberType, loggingEnabled: Bool) {
        
        // TODO: Shouldn't force unwrap here. ~Levi
        self.remoteUrl = URL(string: config.getTractRemoteShareConnectionUrl())!
        self.webSocket = webSocket
        self.webSocketChannelSubscriber = webSocketChannelSubscriber
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        unsubscribe(disconnectSocket: true)
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.isConnected
    }
    
    var isSubscribedToChannel: Bool {
        return webSocketChannelSubscriber.isSubscribedToChannel
    }
    
    func subscribe(channelId: String, complete: @escaping ((_ error: TractRemoteShareSubscriberError?) -> Void)) {
            
        log(method: "subscribe()", label: "channelId", labelValue: channelId)
        
        unsubscribe(disconnectSocket: false)
            
        didSubscribeToChannelClosure = complete
        addObservers()
        startTimeoutTimer()
        webSocketChannelSubscriber.subscribe(url: remoteUrl, channelId: channelId)
    }
    
    func unsubscribe(disconnectSocket: Bool) {
        
        webSocketChannelSubscriber.unsubscribe()
        removeObsevers()
        stopTimeoutTimer()
        didSubscribeToChannelClosure = nil
        subscribedToChannelObserver.accept(value: false)
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
    
    private func handleDidSubscribeToChannel(channelId: String?, error: TractRemoteShareSubscriberError?) {
        
        log(method: "handleDidSubscribeToChannel()", label: "channelId", labelValue: channelId)
        
        stopTimeoutTimer()
        didSubscribeToChannelClosure?(error)
        didSubscribeToChannelClosure = nil
        subscribedToChannelObserver.accept(value: isSubscribedToChannel)
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        
        if !isObservingSignals {
            
            isObservingSignals = true
            
            webSocketChannelSubscriber.didSubscribeToChannelSignal.addObserver(self) { [weak self] (channelId: String) in
                self?.handleDidSubscribeToChannel(channelId: channelId, error: nil)
            }
            
            webSocket.didReceiveTextSignal.addObserver(self) { [weak self] (text: String) in
                self?.handleDidReceiveText(text: text)
            }
        }
    }
    
    private func removeObsevers() {
        
        if isObservingSignals {
            
            isObservingSignals = false
            
            webSocketChannelSubscriber.didSubscribeToChannelSignal.removeObserver(self)
            webSocket.didReceiveTextSignal.removeObserver(self)
        }
    }
    
    // MARK:  Timeout Timer
    
    private func startTimeoutTimer() {
        
        stopTimeoutTimer()
        
        timeoutTimer = Timer.scheduledTimer(
            timeInterval: TractRemoteShareSubscriber.timeoutIntervalSeconds,
            target: self,
            selector: #selector(handleTimeoutTimer),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc func handleTimeoutTimer() {
        stopTimeoutTimer()
        if !isSubscribedToChannel {
            handleDidSubscribeToChannel(channelId: nil, error: .timedOut)
        }
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    // MARK: - Log
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteShareSubscriber \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
        }
    }
}

// MARK: - Events

extension TractRemoteShareSubscriber {
    
    private func handleDidReceiveText(text: String) {
            
        log(method: "handleDidReceiveText()", label: "text", labelValue: text)
        
        let data: Data? = text.data(using: .utf8)
        
        let object: TractRemoteShareNavigationEvent? = jsonServices.decodeObject(data: data)
                
        if let object = object, object.message?.data?.type == "navigation-event" {
            
            navigationEventSignal.accept(value: object)
        }
    }
}
