//
//  TutorialCellViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class TutorialCellViewModel {
    
    enum CustomViewId: String {
        case tutorialTools = "tutorial_tools"
        case tutorialInMenu = "tutorial_in_menu"
    }
    
    let title: String
    let message: String
    let mainImage: UIImage?
    let youTubeVideoId: String
    let customView: UIView
    let hidesCustomView: Bool
    let hidesYouTubeVideoPlayer: Bool
    let hidesMainImage: Bool
    
    required init(item: TutorialItem, deviceLanguage: DeviceLanguageType) {
        
        title = item.title
        message = item.message
        mainImage = UIImage(named: item.imageName ?? "")
        youTubeVideoId = item.youTubeVideoId ?? ""
        
        let customViewId: CustomViewId? = CustomViewId(rawValue: item.customViewId ?? "")
        if let customViewId = customViewId {
            switch customViewId {
            case .tutorialTools:
                let tutorialTools: TutorialToolsView = TutorialToolsView()
                tutorialTools.configure(viewModel: TutorialToolsViewModel(deviceLanguage: deviceLanguage))
                customView = tutorialTools
                
            case .tutorialInMenu:
                let tutorialInMenu: TutorialInMenuView = TutorialInMenuView()
                tutorialInMenu.configure(viewModel: TutorialInMenuViewModel(deviceLanguage: deviceLanguage))
                customView = tutorialInMenu
            }
        }
        else {
            customView = UIView(frame: .zero)
        }
        
        if mainImage != nil {
            hidesMainImage = false
            hidesYouTubeVideoPlayer = true
            hidesCustomView = true
        }
        else if !youTubeVideoId.isEmpty {
            hidesMainImage = true
            hidesYouTubeVideoPlayer = false
            hidesCustomView = true
        }
        else if customViewId != nil {
            hidesMainImage = true
            hidesYouTubeVideoPlayer = true
            hidesCustomView = false
        }
        else {
            hidesMainImage = false
            hidesYouTubeVideoPlayer = true
            hidesCustomView = true
        }
    }
}
