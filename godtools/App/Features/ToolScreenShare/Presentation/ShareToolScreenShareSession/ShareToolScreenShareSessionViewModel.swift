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
    private let domainModel: ShareToolScreenShareSessionDomainModel
    private let shareUrl: String
    
    let shareMessage: String
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate?, domainModel: ShareToolScreenShareSessionDomainModel, shareMessage: String, shareUrl: String, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
            
        self.flowDelegate = flowDelegate
        self.domainModel = domainModel
        self.shareMessage = shareMessage
        self.shareUrl = shareUrl
        
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
    
    func qrCodeTapped() {
        // MARK: - TODO: Complete in GT-2578 subtask. ~Levi
    }
}
