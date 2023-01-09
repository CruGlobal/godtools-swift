//
//  ShareToolViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 5/13/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import Combine

class ShareToolViewModel: ShareToolViewModelType {
        
    private let resource: ResourceModel
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let incrementUserCounterUseCase: IncrementUserCounterUseCase
    private let analytics: AnalyticsContainer
    private let pageNumber: Int
    
    let shareMessage: String
    
    private var cancellables = Set<AnyCancellable>()
    
    init(resource: ResourceModel, language: LanguageDomainModel, pageNumber: Int, localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, incrementUserCounterUseCase: IncrementUserCounterUseCase, analytics: AnalyticsContainer) {
                
        self.resource = resource
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.incrementUserCounterUseCase = incrementUserCounterUseCase
        self.analytics = analytics
        self.pageNumber = pageNumber
        
        var shareUrlString: String = "https://www.knowgod.com/\(language.localeIdentifier)/\(resource.abbreviation)"

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
        
        incrementUserCounterUseCase.incrementUserCounter(for: .linkShared)?
            .sink { _ in
                
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
}
