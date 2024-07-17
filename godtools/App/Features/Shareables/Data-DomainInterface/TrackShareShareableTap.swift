//
//  TrackShareShareableTap.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

class TrackShareShareableTap: TrackShareShareableTapInterface {
    
    private let trackActionAnalytics: TrackActionAnalytics
    private let resourcesRepository: ResourcesRepository
    
    init(trackActionAnalytics: TrackActionAnalytics, resourcesRepository: ResourcesRepository) {
        
        self.trackActionAnalytics = trackActionAnalytics
        self.resourcesRepository = resourcesRepository
    }
    
    func trackShareShareableTapPublisher(toolId: String, shareableId: String) -> AnyPublisher<Void, Never> {
        
        let resource: ResourceModel? = resourcesRepository.getResource(id: toolId)
        
        let action = TrackActionModel(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            siteSection: resource?.abbreviation ?? "",
            siteSubSection: "",
            contentLanguage: nil,
            secondaryContentLanguage: nil,
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareableId]
        )
        
        trackActionAnalytics.trackAction(trackAction: action)
        
        return Just(())
            .eraseToAnyPublisher()
    }
}
