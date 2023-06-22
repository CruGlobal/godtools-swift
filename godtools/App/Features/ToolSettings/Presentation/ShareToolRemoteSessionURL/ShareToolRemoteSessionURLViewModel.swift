//
//  ShareToolRemoteSessionURLViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/14/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ShareToolRemoteSessionURLViewModel {
        
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    
    let shareMessage: String
    
    init(toolRemoteShareUrl: String, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer) {
              
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        
        shareMessage = String.localizedStringWithFormat(
            localizationServices.stringForMainBundle(key: "share_tool_remote_link_message"),
            toolRemoteShareUrl
        )
    }
}

// MARK: - Inputs

extension ShareToolRemoteSessionURLViewModel {
    
    func pageViewed() {
        
        let trackAction = TrackActionModel(
            screenName: "",
            actionName: AnalyticsConstants.ActionNames.shareScreenEngaged,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [
                AnalyticsConstants.Keys.shareScreenEngagedCountKey: 1
            ]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}
