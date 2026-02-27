//
//  CreatingToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor class CreatingToolScreenShareSessionViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
        
    private let toolId: String
    private let createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger
    private let getCurrentAppLanguage: GetCurrentAppLanguageUseCase
    private let viewCreatingToolScreenShareSessionUseCase: ViewCreatingToolScreenShareSessionUseCase
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var creatingSessionMessage: String = ""
    
    init(flowDelegate: FlowDelegate, toolId: String, createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger, getCurrentAppLanguage: GetCurrentAppLanguageUseCase, viewCreatingToolScreenShareSessionUseCase: ViewCreatingToolScreenShareSessionUseCase, tractRemoteSharePublisher: TractRemoteSharePublisher, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.toolId = toolId
        self.createSessionTrigger = createSessionTrigger
        self.getCurrentAppLanguage = getCurrentAppLanguage
        self.viewCreatingToolScreenShareSessionUseCase = viewCreatingToolScreenShareSessionUseCase
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        getCurrentAppLanguage
            .execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$appLanguage)
        
        $appLanguage
            .dropFirst()
            .map { (appLanguage: AppLanguageDomainModel) in
                
                viewCreatingToolScreenShareSessionUseCase
                    .viewPublisher(appLanguage: appLanguage)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionDomainModel) in
                
                let interfaceStrings: CreatingToolScreenShareSessionInterfaceStringsDomainModel = domainModel.interfaceStrings
                
                self?.creatingSessionMessage = interfaceStrings.creatingSessionMessage
            }
            .store(in: &cancellables)
        
        tractRemoteSharePublisher
            .didCreateChannelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (channel: WebSocketChannel) in
                
                self?.didCreateNewSubscriberChannelForPublish(result: .success(channel))
            }
            .store(in: &cancellables)
        
        tractRemoteSharePublisher
            .didFailToCreateChannelPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (error: TractRemoteSharePublisherError) in
                
                self?.didCreateNewSubscriberChannelForPublish(result: .failure(error))
            }
            .store(in: &cancellables)
        
        
        tractRemoteSharePublisher
            .createChannelForPublish()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func didCreateNewSubscriberChannelForPublish(result: Result<WebSocketChannel, TractRemoteSharePublisherError>) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.flowDelegate?.navigate(
                step: .didCreateSessionFromCreatingToolScreenShareSession(
                    result: result,
                    createSessionTrigger: weakSelf.createSessionTrigger
                )
            )
        }
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionViewModel {
    
    @objc func closeTapped() {
        
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        flowDelegate?.navigate(step: .closeTappedFromCreatingToolScreenShareSession)
    }
    
    func pageViewed() {
        
        incrementUserCounterUseCase
            .execute(
                interaction: .screenShare(tool: toolId)
            )
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &Self.backgroundCancellables)
    }
}
