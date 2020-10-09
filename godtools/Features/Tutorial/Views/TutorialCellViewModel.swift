//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialCellViewModel {
        
    let title: String
    let message: String
    let mainImage: UIImage?
    let youTubeVideoId: String
    let animationName: String
    let customView: UIView
    let hidesCustomView: Bool
    let hidesYouTubeVideoPlayer: Bool
    let hidesAnimationView: Bool
    let hidesMainImage: Bool
    
    required init(item: TutorialItem, customViewBuilder: CustomViewBuilderType) {
        
        title = item.title
        message = item.message
        if let imageName = item.imageName, !imageName.isEmpty {
            mainImage = UIImage(named: imageName)
        }
        else {
            mainImage = nil
        }
        youTubeVideoId = item.youTubeVideoId ?? ""
        animationName = item.animationName ?? ""
        
        let didBuildCustomView: Bool
        if let customViewId = item.customViewId, !customViewId.isEmpty, let builtCustomView = customViewBuilder.buildCustomView(customViewId: customViewId) {
            customView = builtCustomView
            didBuildCustomView = true
        }
        else {
            customView = UIView(frame: .zero)
            didBuildCustomView = false
        }
        
        if mainImage != nil {
            hidesMainImage = false
            hidesYouTubeVideoPlayer = true
            hidesCustomView = true
            hidesAnimationView = true
        }
        else if !youTubeVideoId.isEmpty {
            hidesMainImage = true
            hidesYouTubeVideoPlayer = false
            hidesCustomView = true
            hidesAnimationView = true
        }
        else if didBuildCustomView {
            hidesMainImage = true
            hidesYouTubeVideoPlayer = true
            hidesCustomView = false
            hidesAnimationView = true
        }
        else if animationName != nil {
            hidesMainImage = true
            hidesYouTubeVideoPlayer = true
            hidesCustomView = true
            hidesAnimationView = false
        }
        else {
            hidesMainImage = false
            hidesYouTubeVideoPlayer = true
            hidesCustomView = true
            hidesAnimationView = true
        }
    }
}
