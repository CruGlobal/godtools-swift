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
    
    let message: ObservableValue<String> = ObservableValue(value: "")
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tractRemoteSharePublisher: TractRemoteSharePublisher, tractRemoteShareURLBuilder: TractRemoteShareURLBuilder, resource: ResourceModel, primaryLanguage: LanguageModel, parallelLanguage: LanguageModel?) {
        
        self.flowDelegate = flowDelegate
        
        tractRemoteSharePublisher.createNewSubscriberChannelIdForPublish { [weak self] (channel: TractRemoteShareChannel) in
            
            let remoteShareUrl: String? = tractRemoteShareURLBuilder.buildRemoteShareURL(
                resource: resource,
                primaryLanguage: primaryLanguage,
                parallelLanguage: parallelLanguage,
                subscriberChannelId: channel.subscriberChannelId
            )
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in

                self?.flowDelegate?.navigate(step: .finishedLoadingToolRemoteSession(toolRemoteShareUrl: remoteShareUrl))
            }
        }
        
        message.accept(value: localizationServices.stringForMainBundle(key: "load_tool_remote_session.message"))
    }
}
