//
//  OnboardingTutorialIntroViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialIntroViewModel: OnboardingTutorialIntroViewModelType {

    private let getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase
    private let getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analyticsScreenName: String
    private let youtubeVideoId: String
    
    private weak var flowDelegate: FlowDelegate?
    
    let logoImage: UIImage?
    let title: String
    let videoLinkLabel: String
    
    init(flowDelegate: FlowDelegate, getSettingsPrimaryLanguageUseCase: GetSettingsPrimaryLanguageUseCase, getSettingsParallelLanguageUseCase: GetSettingsParallelLanguageUseCase, localizationServices: LocalizationServices, tutorialVideoAnalytics: TutorialVideoAnalytics, analyticsScreenName: String) {
        
        self.flowDelegate = flowDelegate
        
        self.getSettingsPrimaryLanguageUseCase = getSettingsPrimaryLanguageUseCase
        self.getSettingsParallelLanguageUseCase = getSettingsParallelLanguageUseCase
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.analyticsScreenName = analyticsScreenName
                
        logoImage = ImageCatalog.onboardingWelcomeLogo.uiImage
        
        title = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.title")
        
        videoLinkLabel = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.videoLink.title")
        
        youtubeVideoId = "RvhZ_wuxAgE"
    }
    
    func videoLinkTapped() {
        
        flowDelegate?.navigate(step: .videoButtonTappedFromOnboardingTutorial(youtubeVideoId: youtubeVideoId))
        
        tutorialVideoAnalytics.trackVideoPlayed(
            videoId: youtubeVideoId,
            screenName: analyticsScreenName,
            contentLanguage: getSettingsPrimaryLanguageUseCase.getPrimaryLanguage()?.analyticsContentLanguage,
            secondaryContentLanguage: getSettingsParallelLanguageUseCase.getParallelLanguage()?.analyticsContentLanguage
        )
    }
}
