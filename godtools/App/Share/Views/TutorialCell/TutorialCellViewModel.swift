//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialCellViewModel: TutorialCellViewModelType {
        
    private let item: TutorialItemType
    private let tutorialVideoAnalytics: TutorialVideoAnalytics
    private let analyticsScreenName: String
    
    private var trackedAnalyticsForYouTubeVideoIds: [String] = Array()
    
    let assetContent: TutorialAssetContent
    let title: String
    let message: String
    
    required init(item: TutorialItemType, customViewBuilder: CustomViewBuilderType?, tutorialVideoAnalytics: TutorialVideoAnalytics, analyticsScreenName: String) {
        
        self.item = item
        self.tutorialVideoAnalytics = tutorialVideoAnalytics
        self.analyticsScreenName = analyticsScreenName
        
        if let imageName = item.imageName, !imageName.isEmpty, let image = UIImage(named: imageName) {
            
            assetContent = .image(image: image)
        }
        else if let animationName = item.animationName, !animationName.isEmpty {
            
            let animatedViewModel = AnimatedViewModel(
                animationDataResource: .mainBundleJsonFile(filename: animationName),
                autoPlay: true,
                loop: true
            )
            
            assetContent = .animation(viewModel: animatedViewModel)
        }
        else if let youTubeVideoId = item.youTubeVideoId, !youTubeVideoId.isEmpty {
            
            let playsInFullScreen = 0
            
            let youTubeVideoParameters: [String : Any] = [
                Strings.YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen
            ]
            
            assetContent = .video(youTubeVideoId: youTubeVideoId, youTubeVideoParameters: youTubeVideoParameters)
        }
        else if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder?.buildCustomView(customViewId: customViewId) {
            
            assetContent = .customView(customView: builtCustomView)
        }
        else {
            
            assetContent = .none
        }
        
        title = item.title
        message = item.message
    }
    
    func getYouTubeVideoId() -> String? {
            return item.youTubeVideoId
        }
    
    func tutorialVideoPlayTapped() {
                
        guard let videoId = getYouTubeVideoId() else {
            return
        }
        
        let youTubeVideoTracked: Bool = trackedAnalyticsForYouTubeVideoIds.contains(videoId)
        
        if !youTubeVideoTracked {
            
            trackedAnalyticsForYouTubeVideoIds.append(videoId)
            
            tutorialVideoAnalytics.trackVideoPlayed(videoId: videoId, screenName: analyticsScreenName)
        }
    }
}
