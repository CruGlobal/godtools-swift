//
//  OnboardingTutorialIntroViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 9/30/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class OnboardingTutorialIntroViewModel: OnboardingTutorialIntroViewModelType {

    let logoImage: UIImage?
    let title: String
    let videoLinkLabel: String
    let youtubeVideoId: String
    
    private let analyticsContainer: AnalyticsContainer
    private let analyticsScreenName: String
    
    private var youTubeVideoTracked: Bool

    required init(localizationServices: LocalizationServices, analyticsContainer: AnalyticsContainer, analyticsScreenName: String) {
        
        logoImage = UIImage(named: "onboarding_welcome_logo")
        title = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.title")
        videoLinkLabel = localizationServices.stringForMainBundle(key: "onboardingTutorial.0.videoLink.title")
        youtubeVideoId = "RvhZ_wuxAgE"
        
        self.analyticsContainer = analyticsContainer
        self.analyticsScreenName = analyticsScreenName
        
        youTubeVideoTracked = false
    }
    
    func videoLinkTapped() {
        
        if !youTubeVideoTracked {
            
            youTubeVideoTracked = true
            
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: analyticsScreenName,
                    actionName: "Tutorial Video",
                    siteSection: "",
                    siteSubSection: "",
                    url: nil,
                    data: ["cru.tutorial_video": 1, "video_id": youtubeVideoId]
                )
            )
        }
    }
}
