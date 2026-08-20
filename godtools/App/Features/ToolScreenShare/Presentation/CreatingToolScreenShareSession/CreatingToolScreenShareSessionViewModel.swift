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
            
    private static let showCreatingSessionForMinSeconds: TimeInterval = 2
    
    private let stepEmitter: FlowStepEmitter
    private let toolId: String
    private let createSessionTrigger: ToolScreenShareFlowCreateSessionTrigger
    private let getCurrentAppLanguageUseCase: GetCurrentAppLanguageUseCase
    private let getCreatingToolScreenShareSessionStringsUseCase: GetCreatingToolScreenShareSessionStringsUseCase
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var didCreateChannelTask: Task<Void, Never>?
    private var creatingChannelTask: Task<Void, Error>?
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
        
        didCreateChannelTask = Task { [weak self] in
            
            let createdChannelStream: AsyncStream<WebSocketChannel> = await tractRemoteSharePublisher.getCreatedChannelStream()
                        
            for await channel in createdChannelStream {
                
                self?.didCreateChannelTask?.cancel()
                self?.creatingChannelTask?.cancel()
                
                stepEmitter.emit(
                    step: AppFlowStep.didCreateSessionFromCreatingToolScreenShareSession(
                        result: .success(channel),
                        createSessionTrigger: createSessionTrigger
                    )
                )
            }
        }
        
        creatingChannelTask = Task {
            
            do {
                
                try await Task.sleep(for: .seconds(Self.showCreatingSessionForMinSeconds))
                
                try await tractRemoteSharePublisher.createChannelForPublish()
            }
            catch let error {
                
                stepEmitter.emit(
                    step: AppFlowStep.didCreateSessionFromCreatingToolScreenShareSession(
                        result: .failure(error),
                        createSessionTrigger: createSessionTrigger
                    )
                )
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }

    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getCreatingToolScreenShareSessionStringsUseCase
            .execute(appLanguage: appLanguage)
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionViewModel {
    
    @objc func closeTapped() {
                
        didCreateChannelTask?.cancel()
        creatingChannelTask?.cancel()
        
        let tractRemoteSharePublisher: TractRemoteSharePublisher = self.tractRemoteSharePublisher
        
        Task.detached {
            
            await tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        }
        
        stepEmitter.emit(step: AppFlowStep.closeTappedFromCreatingToolScreenShareSession)
    }
    
    func pageViewed() {
        
        let incrementUserCounterUseCase: IncrementUserCounterUseCase = self.incrementUserCounterUseCase
        let toolId: String = self.toolId
        
        Task.detached {
            
            _ = try await incrementUserCounterUseCase.execute(interaction: .screenShare(tool: toolId))
        }
    }
}
