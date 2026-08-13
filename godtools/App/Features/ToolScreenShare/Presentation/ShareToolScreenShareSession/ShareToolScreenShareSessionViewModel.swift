//
//  ShareToolScreenShareSessionViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/10/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ShareToolScreenShareSessionViewModel {
    
    private let stepEmitter: FlowStepEmitter
    private let appLanguage: AppLanguageDomainModel
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    private let shareUrl: String
    
    let strings: ShareToolScreenShareSessionStringsDomainModel
    let shareMessage: String
        
    init(
        stepEmitter: FlowStepEmitter,
        appLanguage: AppLanguageDomainModel,
        shareUrl: String,
        strings: ShareToolScreenShareSessionStringsDomainModel,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
            
        self.stepEmitter = stepEmitter
        self.appLanguage = appLanguage
        self.shareUrl = shareUrl
        self.strings = strings
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
                
        self.shareMessage = String.localizedStringWithFormat(strings.shareMessage, shareUrl)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}

// MARK: - Inputs

extension ShareToolScreenShareSessionViewModel {
    
    func pageViewed() {
        
        trackActionAnalyticsUseCase.trackAction(
            properties: AnalyticsProperties(
                screenName: "",
                siteSection: "",
                siteSubSection: "",
                appLanguage: nil,
                contentLanguage: nil,
                secondaryContentLanguage: nil
            ),
            actionName: AnalyticsConstants.ActionNames.shareScreenEngaged,
            data: [
                AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
            ]
        )
    }
    
    func qrCodeTapped() {
    
        stepEmitter.emit(step: AppFlowStep.shareQRCodeTappedFromToolScreenShareSession(shareUrl: shareUrl))
    }
    
    func activityViewDismissed() {
        
        stepEmitter.emit(step: AppFlowStep.dismissedShareToolScreenShareActivityViewController)
    }
}
