//
//  CreatingToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import Combine

class CreatingToolScreenShareSessionViewModel: ObservableObject {
    
    private static var incrementScreenShareInBackgroundCancellable: AnyCancellable?
    
    private let resourceId: String // TODO: Eventually we will want to use ToolDomainModel here. ~Levi
    private let getCurrentAppLanguage: GetCurrentAppLanguageUseCase
    private let viewCreatingToolScreenShareSessionUseCase: ViewCreatingToolScreenShareSessionUseCase
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var creatingSessionMessage: String = ""
    
    init(flowDelegate: FlowDelegate, resourceId: String, getCurrentAppLanguage: GetCurrentAppLanguageUseCase, viewCreatingToolScreenShareSessionUseCase: ViewCreatingToolScreenShareSessionUseCase, tractRemoteSharePublisher: TractRemoteSharePublisher, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resourceId = resourceId
        self.getCurrentAppLanguage = getCurrentAppLanguage
        self.viewCreatingToolScreenShareSessionUseCase = viewCreatingToolScreenShareSessionUseCase
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        getCurrentAppLanguage
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        viewCreatingToolScreenShareSessionUseCase
            .viewPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (domainModel: CreatingToolScreenShareSessionDomainModel) in
                
                let interfaceStrings: CreatingToolScreenShareSessionInterfaceStringsDomainModel = domainModel.interfaceStrings
                
                self?.creatingSessionMessage = interfaceStrings.creatingSessionMessage
            }
            .store(in: &cancellables)
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .didCreateSessionFromCreatingToolScreenShareSession(result: result))
            }
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension CreatingToolScreenShareSessionViewModel {
    
    @objc func closeTapped() {
        
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        flowDelegate?.navigate(step: .closeTappedFromCreatingToolScreenShareSession)
    }
    
    func pageViewed() {
        
        CreatingToolScreenShareSessionViewModel.incrementScreenShareInBackgroundCancellable = incrementUserCounterUseCase.incrementUserCounter(for: .screenShare(tool: resourceId))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
    }
}
