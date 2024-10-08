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
    
    init(shareMessage: String, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
            
        self.shareMessage = shareMessage
        
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            appLanguage: nil,
            contentLanguage: nil,
            contentLanguageSecondary: nil,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
            ]
        )
    }
}
