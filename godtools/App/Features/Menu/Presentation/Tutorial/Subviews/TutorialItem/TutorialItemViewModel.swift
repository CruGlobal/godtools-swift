//
//  TutorialItemViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/7/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation
import UIKit

class TutorialItemViewModel: ObservableObject {
    
    private let tutorialItem: TutorialItemDomainModel
    
    init(tutorialItem: TutorialItemDomainModel) {
        
        self.tutorialItem = tutorialItem
    }
    
    var title: String {
        return tutorialItem.title
    }
    
    var message: String {
        return tutorialItem.message
    }
    
    var animatedViewModel: AnimatedViewModel? {
        
        guard let animationName = tutorialItem.animationName, !animationName.isEmpty else {
            return nil
        }
        
        let animatedResource: AnimatedResource = .mainBundleJsonFile(filename: animationName)
        
        return AnimatedViewModel(animationDataResource: animatedResource, autoPlay: true, loop: true)
    }
    
    var imageName: String? {
        return tutorialItem.imageName
    }
    
    var youtubeVideoId: String? {
        return tutorialItem.youTubeVideoId
    }
    
    var youtubePlayerParameters: [String: Any] {
        
        let playsInFullScreen: Int = 0
        let playerParameters: [String: Any] = [YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen]
        
        return playerParameters
    }
}
