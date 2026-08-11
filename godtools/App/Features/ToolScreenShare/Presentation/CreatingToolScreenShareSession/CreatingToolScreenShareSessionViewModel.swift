//
//  CreatingToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

@MainActor
final class CreatingToolScreenShareSessionViewModel: ObservableObject {
    
    private static var backgroundCancellables: Set<AnyCancellable> = Set()
        
    private let stepEmitter: FlowStepEmitter
    private let toolId: String
    private let createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getCreatingToolScreenShareSessionStringsUseCase: GetCreatingToolScreenShareSessionStringsUseCase
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var cancellables = Set<AnyCancellable>()
        
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published private(set) var strings = CreatingToolScreenShareSessionStringsDomainModel.emptyValue
        
    init(
        stepEmitter: FlowStepEmitter,
        toolId: String,
        createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger,
        getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase,
        getCreatingToolScreenShareSessionStringsUseCase: GetCreatingToolScreenShareSessionStringsUseCase,
        tractRemoteSharePublisher: TractRemoteSharePublisher,
        incrementUserCounterUseCase: IncrementUserCounterUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.toolId = toolId
        self.createSessionTrigger = createSessionTrigger
        self.getCurrentAppLanguageUseCase = getCurrentAppLanguageUseCase
        self.getCreatingToolScreenShareSessionStringsUseCase = getCreatingToolScreenShareSessionStringsUseCase
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        getCurrentAppLanguageUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (appLanguage: AppLanguageDomainModel) in

                self?.appLanguage = appLanguage
                self?.didSetAppLanguage(appLanguage: appLanguage)
            })
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

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        Task {

            strings = await getCreatingToolScreenShareSessionStringsUseCase
                .execute(appLanguage: appLanguage)
        }
    }

    private func didCreateNewSubscriberChannelForPublish(result: Result<WebSocketChannel, TractRemoteSharePublisherError>) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            
            weakSelf.stepEmitter.emit(
                step: AppFlowStep.didCreateSessionFromCreatingToolScreenShareSession(
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
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromCreatingToolScreenShareSession)
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
