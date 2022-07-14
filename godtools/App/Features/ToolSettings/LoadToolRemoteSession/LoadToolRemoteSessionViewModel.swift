//
//  LoadToolRemoteSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LoadToolRemoteSessionViewModel: LoadingViewModelType {
    
    private let tractRemoteSharePublisher: TractRemoteSharePublisher
    
    private weak var flowDelegate: FlowDelegate?
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    let hidesCloseButton: Bool = false
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tractRemoteSharePublisher: TractRemoteSharePublisher) {
        
        self.flowDelegate = flowDelegate
        self.tractRemoteSharePublisher = tractRemoteSharePublisher
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (result: Result<TractRemoteShareChannel, TractRemoteSharePublisherError>) in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .finishedLoadingToolRemoteSession(result: result))
            }
        }
        
        message.accept(value: localizationServices.stringForMainBundle(key: "load_tool_remote_session.message"))
    }
    
    func closeTapped() {
        
        tractRemoteSharePublisher.endPublishingSession(disconnectSocket: true)
        
        flowDelegate?.navigate(step: .cancelledLoadingToolRemoteSession)
    }
}
