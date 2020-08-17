//
//  LoadToolRemoteSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/15/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class LoadToolRemoteSessionViewModel: LoadingViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let message: ObservableValue<String> = ObservableValue(value: "Starting remote session...")
    
    required init(flowDelegate: FlowDelegate, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareURLBuilder: TractRemoteShareURLBuilder, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?) {
        
        self.flowDelegate = flowDelegate
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (channel: TractRemoteShareChannel) in
            
            let remoteShareUrl: URL? = tractRemoteShareURLBuilder.buildRemoteShareURL(
                resource: resource,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage,
                subscriberChannelId: channel.subscriberChannelId
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .finishedLoadingToolRemoteSession(toolRemoteShareUrl: remoteShareUrl))
            }
        }
    }
}
