//
//  ShareArticleViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 4/28/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

@MainActor
final class ShareArticleViewModel {
    
    private let stepEmitter: FlowStepEmitter
    private let trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase
    private let trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    
    let shareArticle: ShareArticleDomainModel
        
    init(
        stepEmitter: FlowStepEmitter,
        shareArticle: ShareArticleDomainModel,
        trackScreenViewAnalyticsUseCase: TrackScreenViewAnalyticsUseCase,
        trackActionAnalyticsUseCase: TrackActionAnalyticsUseCase
    ) {
        
        self.stepEmitter = stepEmitter
        self.shareArticle = shareArticle
        self.trackScreenViewAnalyticsUseCase = trackScreenViewAnalyticsUseCase
        self.trackActionAnalyticsUseCase = trackActionAnalyticsUseCase
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private var analyticsScreenName: String {
        return shareArticle.analyticsScreenName
    }
    
    private var analyticsSiteSection: String {
        return "articles"
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        Task {
            await trackScreenViewAnalyticsUseCase.execute(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                )
            )
        }
    }
    
    func articleShared() {
                
        Task {
            await trackActionAnalyticsUseCase.trackAction(
                properties: AnalyticsProperties(
                    screenName: analyticsScreenName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubSection,
                    appLanguage: nil,
                    contentLanguage: nil,
                    secondaryContentLanguage: nil
                ),
                actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
                data: [AnalyticsConstants.Keys.shareAction: 1]
            )
        }
    }
    
    func activityViewDismissed() {
        
        stepEmitter.emit(step: AppFlowStep.dismissedShareArticleActivityViewController)
    }
}
