//
//  CreatingToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine
import Flow

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
    
    private var getConnectionStateStreamTask: Task<Void, Never>?
    private var didCreateChannelTask: Task<Void, Error>?
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
        
        startCreateChannel()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        getConnectionStateStreamTask?.cancel()
        didCreateChannelTask?.cancel()
        creatingChannelTask?.cancel()
    }

    private func cancelCreateChannelTasks() {
        getConnectionStateStreamTask?.cancel()
        didCreateChannelTask?.cancel()
        creatingChannelTask?.cancel()
    }
    
    private func didSetAppLanguage(appLanguage: AppLanguageDomainModel) {

        strings = getCreatingToolScreenShareSessionStringsUseCase
            .execute(appLanguage: appLanguage)
    }
    
    private func startCreateChannel() {
        
        observeConnectionStateStream()
        
        observeDidCreateChannelStream()
        
        createChannel()
    }
    
    private func observeConnectionStateStream() {
        
        getConnectionStateStreamTask = Task { [weak self] in
        
            guard let stream = await self?.tractRemoteSharePublisher.getConnectionStateStream() else {
                return
            }
            
            for await connectionState in stream {
                
                switch connectionState {
                case .disconnected(let reason):
                    switch reason {
                    case .clientDisconnected:
                        break
                    case .didClose( _):
                        break
                    case .taskFinishedTransfer(let error):
                        if let error = error {
                            self?.cancelCreateChannelTasks()
                            self?.emitDidCreateSessionStep(result: .failure(error))
                        }
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func observeDidCreateChannelStream() {
                        
        didCreateChannelTask = Task { [weak self] in
            
            guard let createdChannelStream: AsyncThrowingStream<WebSocketChannel, Error> = await self?.tractRemoteSharePublisher.getCreatedChannelStream() else {
                return
            }
            
            do {
                
                for try await channel in createdChannelStream {
                    
                    self?.cancelCreateChannelTasks()
                    
                    self?.emitDidCreateSessionStep(result: .success(channel))
                }
            }
            catch let error {
                
                self?.cancelCreateChannelTasks()
                
                self?.emitDidCreateSessionStep(result: .failure(error))
            }
        }
    }
    
    private func createChannel() {
                        
        creatingChannelTask = Task { [weak self] in
            
            do {
                
                try await Task.sleep(for: .seconds(Self.showCreatingSessionForMinSeconds))
                
                try await self?.tractRemoteSharePublisher.createChannelForPublish()
            }
            catch let error {
                
                self?.cancelCreateChannelTasks()
                
                self?.emitDidCreateSessionStep(result: .failure(error))
            }
        }
    }
    
    private func emitDidCreateSessionStep(result: Result<WebSocketChannel, Error>) {
        
        stepEmitter.emit(
            step: AppFlowStep.didCreateSessionFromCreatingToolScreenShareSession(
                result: result,
                createSessionTrigger: createSessionTrigger
            )
        )
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionViewModel {
    
    @objc func closeTapped() {
                
        cancelCreateChannelTasks()
        
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
