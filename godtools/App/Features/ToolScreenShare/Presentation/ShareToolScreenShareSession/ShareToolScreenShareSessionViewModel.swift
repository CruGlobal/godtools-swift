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
    private let shareUrl: String
    
    let strings: ShareToolScreenShareSessionStringsDomainModel
    let shareMessage: String
    
    private weak var flowDelegate: FlowDelegate?
    
    init(flowDelegate: FlowDelegate?, strings: ShareToolScreenShareSessionStringsDomainModel, shareMessage: String, shareUrl: String, trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase) {
            
        self.flowDelegate = flowDelegate
        self.strings = strings
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
    
        flowDelegate?.navigate(step: .shareQRCodeTappedFromToolScreenShareSession(shareUrl: shareUrl))
    }
    
    func activityViewDismissed() {
        
        flowDelegate?.navigate(step: .dismissedShareToolScreenShareActivityViewController)
    }
}
