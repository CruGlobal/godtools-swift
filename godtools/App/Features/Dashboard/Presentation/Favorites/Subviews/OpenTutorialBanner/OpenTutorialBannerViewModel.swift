//
//  OpenTutorialBannerViewModel.swift
//  godtools
//
//  Created by Rachael Skeath on 6/27/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

protocol OpenTutorialBannerViewModelDelegate: AnyObject {
    func closeBanner()
    func openTutorial()
}

class OpenTutorialBannerViewModel: ObservableObject {
        
    private let localizationServices: LocalizationServices
    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let analytics: AnalyticsContainer
    
    private weak var delegate: OpenTutorialBannerViewModelDelegate?
        
    @Published var showTutorialText: String
    @Published var openTutorialButtonText: String
        
    init(localizationServices: LocalizationServices, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, analytics: AnalyticsContainer, delegate: OpenTutorialBannerViewModelDelegate?) {
        
        self.localizationServices = localizationServices
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.analytics = analytics
        self.delegate = delegate
        
        showTutorialText = localizationServices.stringForSystemElseEnglish(key: "openTutorial.showTutorialLabel.text")
        openTutorialButtonText = localizationServices.stringForSystemElseEnglish(key: "openTutorial.openTutorialButton.title")
    }
    
    private var analyticsScreenName: String {
        return "home"
    }
    
    private func trackCloseTapped() {
        
        let trackAction = TrackActionModel(
            screenName: analyticsScreenName,
            actionName: AnalyticsConstants.ActionNames.tutorialHomeDismiss,
            siteSection: "",
            siteSubSection: "",
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage,
            url: nil,
            data: [AnalyticsConstants.Keys.tutorialDismissed: 1]
        )
        
        analytics.trackActionAnalytics.trackAction(trackAction: trackAction)
    }
}

// MARK: - Inputs

extension OpenTutorialBannerViewModel {
    
    func closeTapped() {
        delegate?.closeBanner()
        trackCloseTapped()
    }
    
    func openTutorialButtonTapped() {
        delegate?.openTutorial()
    }
}
