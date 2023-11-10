//
//  ShareToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class ShareToolScreenShareSessionViewModel {
    
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    let shareMessage: String
    
    init(domainModel: ShareToolScreenShareSessionDomainModel, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
              
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
        
        let interfaceStrings: ShareToolScreenShareSessionInterfaceStringsDomainModel = domainModel.interfaceStrings
        
        shareMessage = interfaceStrings.shareMessage
    }
}

// MARK: - Inputs

extension ShareToolScreenShareSessionViewModel {
    
    func pageViewed() {
        
        trackActionAnalyticsUseCase.trackAction(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareScreenEngaged,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
            ]
        )
    }
}
