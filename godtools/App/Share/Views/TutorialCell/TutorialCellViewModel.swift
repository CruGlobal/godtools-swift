//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialCellViewModel: TutorialCellViewModelType {
        
    let title: String
    let message: String
    let mainImageName: String?
    let youTubeVideoId: String?
    let animationName: String?
    let customView: UIView?
    
    private let analyticsContainer: AnalyticsContainer
    private let analyticsScreenName: String
    private let analyticsSiteSection: String
    private let analyticsSiteSubsection: String
    private let analyticsVideoActionName: String
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    
    required init(item: TutorialItemType, customViewBuilder: CustomViewBuilderType?, analyticsContainer: AnalyticsContainer, analyticsScreenName: String, analyticsSiteSection: String, analyticsSiteSubsection: String, analyticsVideoActionName: String) {
        
        title = item.title
        message = item.message
        mainImageName = item.imageName
        youTubeVideoId = item.youTubeVideoId
        animationName = item.animationName
        
        self.analyticsContainer = analyticsContainer
        self.analyticsScreenName = analyticsScreenName
        self.analyticsSiteSection = analyticsSiteSection
        self.analyticsSiteSubsection = analyticsSiteSubsection
        self.analyticsVideoActionName = analyticsVideoActionName
        
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder?.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
        }
        else {
            customView = nil
        }
    }
    
    func tutorialVideoPlayTapped() {
                
        guard let videoId = youTubeVideoId, !analyticsVideoActionName.isEmpty else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: analyticsScreenName,
                    actionName: analyticsVideoActionName,
                    siteSection: analyticsSiteSection,
                    siteSubSection: analyticsSiteSubsection,
                    url: nil,
                    data: ["cru.tutorial_video": 1, "video_id": videoId]
                )
            )
        }
    }
}
