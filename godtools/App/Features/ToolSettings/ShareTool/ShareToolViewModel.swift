//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolViewModel: ShareToolViewModelType {
        
    private let resource: ResourceModel
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    private let pageNumber: Int
    
    let shareMessage: String
    
    init(resource: ResourceModel, language: LanguageModel, pageNumber: Int, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer) {
                
        self.resource = resource
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.pageNumber = pageNumber
        
        var shareUrlString: String = "https://www.knowgod.com/\(language.code)/\(resource.abbreviation)"

        if pageNumber > 0 {
            shareUrlString = shareUrlString.appending("/").appending("\(pageNumber)")
        }
        
        shareUrlString = shareUrlString.replacingOccurrences(of: " ", with: "").appending("?icid=gtshare ")
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "tract_share_message"),
            shareUrlString
        )
    }
    
    private var analyticsScreenName: String {
        return resource.abbreviation + "-" + String(pageNumber)
    }
    
    private var analyticsSiteSection: String {
        return resource.abbreviation
    }
    
    private var analyticsSiteSubSection: String {
        return ""
    }
    
    func pageViewed() {
        
        let trackScreen = TrackScreenModel(
            screenName: analyticsScreenName,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
        
        analytics.pageViewedAnalytics.trackPageView(trackScreen: trackScreen)
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.shareIconEngaged,
            siteSection: analyticsSiteSection,
            siteSubSection: analyticsSiteSubSection,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareAction: 1
            ]
        )
                
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
