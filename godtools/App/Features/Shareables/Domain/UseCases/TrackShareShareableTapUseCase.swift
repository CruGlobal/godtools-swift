//
//  TrackShareShareableTapUseCase.swift
//  godtools
//
//  Created by Levi Eggert on 2/26/24.
//  Copyright © 2024 Cru. All rights reserved.
//

import Foundation
import Combine

final class TrackShareShareableTapUseCase {
    
    private let trackActionAnalytics: TrackActionAnalytics
    private let resourcesRepository: ResourcesRepository
    
    init(trackActionAnalytics: TrackActionAnalytics, resourcesRepository: ResourcesRepository) {
        
        self.trackActionAnalytics = trackActionAnalytics
        self.resourcesRepository = resourcesRepository
    }
    
    func execute(toolId: String, shareableId: String) -> AnyPublisher<Void, Error> {
        
        do {
            
            let resource: ResourceDataModel? = try resourcesRepository.persistence.getDataModel(id: toolId)
            
            let action = TrackActionModel(
                screenName: "",
                actionName: AnalyticsConstants.ActionNames.shareShareable,
                siteSection: resource?.abbreviation ?? "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil,
                url: nil,
                data: [AnalyticsConstants.Keys.shareableId: shareableId]
            )
            
            trackActionAnalytics.trackAction(trackAction: action)
            
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        catch let error {
            
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
