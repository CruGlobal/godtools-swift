//
//  TrackShareShareableTapUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation

final class TrackShareShareableTapUseCase: Sendable {
    
    private let trackActionAnalytics: TrackActionAnalytics
    private let resourcesRepository: ResourcesRepository
    
    init(trackActionAnalytics: TrackActionAnalytics, resourcesRepository: ResourcesRepository) {
        
        self.trackActionAnalytics = trackActionAnalytics
        self.resourcesRepository = resourcesRepository
    }
    
    func execute(toolId: String, shareableId: String) async {
        
        let resource: ResourceDataModel? = resourcesRepository.getResourceById(id: toolId)
        
        let action = TrackActionModel(
            properties: AnalyticsProperties(
                screenName: "",
                siteSection: resource?.abbreviation ?? "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            ),
            actionName: AnalyticsConstants.ActionNames.shareShareable,
            url: nil,
            data: [AnalyticsConstants.Keys.shareableId: shareableId]
        )
        
        await trackActionAnalytics.trackAction(trackAction: action)
    }
}
