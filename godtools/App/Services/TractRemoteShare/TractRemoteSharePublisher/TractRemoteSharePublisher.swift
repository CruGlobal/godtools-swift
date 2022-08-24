//
//  TractRemoteSharePublisher.swift
//  godtools
//
//  Created by Levi Eggert on 8/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class TractRemoteSharePublisher: NSObject {
    
    typealias CreateNewPublisherCompletion = ((_ result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>) -> Void)
    
    private static let timeoutIntervalSeconds: TimeInterval = 10
    
    private let remoteUrl: URL
    private let webSocket: WebSocketType
    private let webSocketChannelPublisher: WebSocketChannelPublisherType
    private let loggingEnabled: Bool
    
    private var timeoutTimer: Timer?
    private var createNewPublisherBlock: CreateNewPublisherCompletion?
    private var isObservingSignals: Bool = false
    
    private(set) var tractRemoteShareChannel: TractRemoteShareChannel?
    
    let didCreateNewSubscriberChannelIdForPublish: SignalValue<TractRemoteShareChannel> = SignalValue()
    
    required init(config: AppConfig, webSocket: WebSocketType, webSocketChannelPublisher: WebSocketChannelPublisherType, loggingEnabled: Bool) {
        
        self.remoteUrl = URL(string: config.tractRemoteShareConnectionUrl)!
        self.webSocket = webSocket
        self.webSocketChannelPublisher = webSocketChannelPublisher
        self.loggingEnabled = loggingEnabled
        
        super.init()
    }
    
    deinit {
        endPublishingSession(disconnectSocket: true)
    }
    
    var webSocketIsConnected: Bool {
        return webSocket.isConnected
    }
    
    var isSubscriberChannelIdCreatedForPublish: Bool {
        return webSocketChannelPublisher.isSubscriberChannelIdCreatedForPublish
    }
    
    var subscriberChannelId: String? {
        return webSocketChannelPublisher.subscriberChannelId
    }
    
    func createNewSubscriberChannelIdForPublish(complete: @escaping CreateNewPublisherCompletion) {
        
        endPublishingSession(disconnectSocket: false)
        
        createNewPublisherBlock = complete
        startTimeoutTimer()
        addObservers()
        
        let channelId: String = UUID().uuidString
        
        webSocketChannelPublisher.createChannelForPublish(url: remoteUrl, channelId: channelId)
    }
    
    func endPublishingSession(disconnectSocket: Bool) {
        
        stopTimeoutTimer()
        tractRemoteShareChannel = nil
        createNewPublisherBlock = nil
        removeObsevers()
        
        if disconnectSocket {
            webSocket.disconnect()
        }
    }
    
    func sendNavigationEvent(event: TractRemoteSharePublisherNavigationEvent) {
                
        let navigationAttributes = TractRemoteShareNavigationEvent.Attributes(card: event.card, locale: event.locale, page: event.page, tool: event.tool)
        let navigationData = TractRemoteShareNavigationEvent.Data(attributes: navigationAttributes)
        let navigationMessage = TractRemoteShareNavigationEvent.Message(data: navigationData)
        
        let stringData: String
            
        do {
            let navigationData: Data = try JSONEncoder().encode(navigationMessage)
            stringData = String(data: navigationData, encoding: .utf8) ?? ""
        }
        catch {
            stringData = ""
        }
                                                
        webSocketChannelPublisher.sendMessage(data: stringData)
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher: sendNavigationEvent()")
            print("  card: \(String(describing: event.card))")
            print("  locale: \(String(describing: event.locale))")
            print("  page: \(String(describing: event.page))")
            print("  tool: \(String(describing: event.tool))")
        }
    }
    
    // MARK: - Observers
    
    private func addObservers() {
        
        if !isObservingSignals {
            
            isObservingSignals = true
            
            webSocketChannelPublisher.didCreateChannelForPublish.addObserver(self) { [weak self] (subscriberChannelId: String) in
                
                self?.stopTimeoutTimer()
                
                let channel = TractRemoteShareChannel(
                    subscriberChannelId: subscriberChannelId
                )
                
                self?.tractRemoteShareChannel = channel
                
                self?.createNewPublisherBlock?(.success(channel))
                
                self?.didCreateNewSubscriberChannelIdForPublish.accept(value: channel)
            }
        }
    }
    
    private func removeObsevers() {
        
        if isObservingSignals {
            
            isObservingSignals = false
            
            webSocketChannelPublisher.didCreateChannelForPublish.removeObserver(self)
        }
    }
    
    // MARK:  Timeout Timer
    
    private func startTimeoutTimer() {
        
        stopTimeoutTimer()
        
        timeoutTimer = Timer.scheduledTimer(
            timeInterval: TractRemoteSharePublisher.timeoutIntervalSeconds,
            target: self,
            selector: #selector(handleTimeoutTimer),
            userInfo: nil,
            repeats: false
        )
    }
    
    @objc func handleTimeoutTimer() {
        stopTimeoutTimer()
        createNewPublisherBlock?(.failure(.timeOut))
    }
    
    private func stopTimeoutTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    // MARK: - Log
    
    private func log(method: String, label: String?, labelValue: String?) {
        
        if loggingEnabled {
            print("\n TractRemoteSharePublisher \(method)")
            if let label = label, let labelValue = labelValue {
               print("  \(label): \(labelValue)")
            }
        }
    }
}
