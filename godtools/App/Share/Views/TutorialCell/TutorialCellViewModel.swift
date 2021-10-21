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
    private let tutorialPagerAnalyticsModel: TutorialPagerAnalytics
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    
    required init(item: TutorialItemType, customViewBuilder: CustomViewBuilderType?, analyticsContainer: AnalyticsContainer, tutorialPagerAnalyticsModel: TutorialPagerAnalytics) {
        
        title = item.title
        message = item.message
        mainImageName = item.imageName
        youTubeVideoId = item.youTubeVideoId
        animationName = item.animationName
        
        self.analyticsContainer = analyticsContainer
        self.tutorialPagerAnalyticsModel = tutorialPagerAnalyticsModel
        
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder?.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
        }
        else {
            customView = nil
        }
    }
    
    func tutorialVideoPlayTapped() {
                
        guard let videoId = youTubeVideoId, !tutorialPagerAnalyticsModel.videoPlayedActionName.isEmpty else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            var data = tutorialPagerAnalyticsModel.videoPlayedData ?? [:]
            
            data["video_id"] = 1
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: tutorialPagerAnalyticsModel.screenName,
                    actionName: tutorialPagerAnalyticsModel.videoPlayedActionName,
                    siteSection: tutorialPagerAnalyticsModel.siteSection,
                    siteSubSection: tutorialPagerAnalyticsModel.siteSubsection,
                    url: nil,
                    data: tutorialPagerAnalyticsModel.videoPlayedData
                )
            )
        }
    }
}
