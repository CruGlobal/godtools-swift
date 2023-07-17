//
//  LoadToolRemoteSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class LoadToolRemoteSessionViewModel: LoadingViewModelType {
    
    private let resourceId: String
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    
    private weak var flowDelegate: FlowDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    let hidesCloseButton: Bool = false
    
    init(resourceId: String, flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tractRemoteSharePublisher: TractRemoteSharePublisher, incrementUserCounterUseCase: IncrementUserCounterUseCase) {
        
        self.resourceId = resourceId
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .finishedLoadingToolRemoteSession(result: result))
            }
        }
        
        message.accept(value: localizationServices.stringForMainBundle(key: "load_tool_remote_session.message"))
    }
}

// MARK: - Inputs

extension LoadToolRemoteSessionViewModel {
    
    func closeTapped() {
        
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        flowDelegate?.navigate(step: .cancelledLoadingToolRemoteSession)
    }
    
    func pageViewed() {
        
        incrementUserCounterUseCase.incrementUserCounter(for: .screenShare(tool: resourceId))
            .sink { _ in
                
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
