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
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    
    required init(item: TutorialItemType, customViewBuilder: CustomViewBuilderType?, analyticsContainer: AnalyticsContainer, analyticsScreenName: String) {
        
        title = item.title
        message = item.message
        mainImageName = item.imageName
        youTubeVideoId = item.youTubeVideoId
        animationName = item.animationName
        
        self.analyticsContainer = analyticsContainer
        self.analyticsScreenName = analyticsScreenName
        
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder?.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
        }
        else {
            customView = nil
        }
    }
    
    func tutorialVideoPlayTapped() {
                
        guard let videoId = youTubeVideoId else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            analyticsContainer.trackActionAnalytics.trackAction(
                trackAction: TrackActionModel(
                    screenName: analyticsScreenName,
                    actionName: "Tutorial Video",
                    siteSection: "",
                    siteSubSection: "",
                    url: nil,
                    data: ["cru.tutorial_video": 1, "video_id": videoId]
                )
            )
        }
    }
}
