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
    private let getCreatingToolScreenShareSessionInterfaceStringsUseCase: GetCreatingToolScreenShareSessionInterfaceStringsUseCase
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
    private weak var flowDelegate: FlowDelegate?
    
    @Published private var appLanguage: AppLanguageCodeDomainModel = LanguageCodeDomainModel.english.value
    
    @Published var loadingMessage: String = ""
    
    init(flowDelegate: FlowDelegate, resourceId: String, getCurrentAppLanguage: GetCurrentAppLanguageUseCase, getCreatingToolScreenShareSessionInterfaceStringsUseCase: GetCreatingToolScreenShareSessionInterfaceStringsUseCase, tractRemoteSharePublisher: TractRemoteSharePublisher, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.flowDelegate = flowDelegate
        self.resourceId = resourceId
        self.getCurrentAppLanguage = getCurrentAppLanguage
        self.getCreatingToolScreenShareSessionInterfaceStringsUseCase = getCreatingToolScreenShareSessionInterfaceStringsUseCase
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        getCurrentAppLanguage
            .getLanguagePublisher()
            .assign(to: &$appLanguage)
        
        getCreatingToolScreenShareSessionInterfaceStringsUseCase
            .getStringsPublisher(appLanguagePublisher: $appLanguage.eraseToAnyPublisher())
            .sink { [weak self] (interfaceStrings: CreatingToolScreenShareSessionInterfaceStringsDomainModel) in
                
                self?.loadingMessage = interfaceStrings.creatingSessionMessage
            }
            .store(in: &cancellables)
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .didCreateSessionFromCreatingToolScreenShareSession(result: result))
            }
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
        
        CreatingToolScreenShareSessionViewModel.incrementScreenShareInBackgroundCancellable = incrementUserCounterUseCase.incrementUserCounter(for: .screenShare(tool: resourceId))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
    }
}