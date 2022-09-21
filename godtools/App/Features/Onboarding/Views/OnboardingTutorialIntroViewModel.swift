//
//  OnboardingTutorialIntroViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialIntroViewModel: OnboardingTutorialIntroViewModelType {

    private weak var flowDelegate: FlowDelegate?
    
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analyticsScreenName: String
    private let youtubeVideoId: String
    
    let logoImage: UIImage?
    let title: String
    let videoLinkLabel: String
    
    required init(flowDelegate: FlowDelegate, localizationServices: LocalizationServices, tutorialVideoAnalytics: TutorialVideoAnalytics, analyticsScreenName: String) {
        
        self.flowDelegate = flowDelegate
        
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.analyticsScreenName = analyticsScreenName
                
        logoImage = ImageCatalog.onboardingWelcomeLogo.uiImage
        
        title = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.title")
        
        videoLinkLabel = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.videoLink.title")
        
        youtubeVideoId = "RvhZ_wuxAgE"
    }
    
    func videoLinkTapped() {
        
        flowDelegate?.navigate(step: .videoButtonTappedFromOnboardingTutorial(youtubeVideoId: youtubeVideoId))
        
        tutorialVideoAnalytics.trackVideoPlayed(videoId: youtubeVideoId, screenName: analyticsScreenName)
    }
}
