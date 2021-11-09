//
//  TutorialCellViewModelType.swift
//  godtools
//
//  Created by Robert Eldredge on 10/11/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol TutorialCellViewModelType {
    
    var assetContent: TutorialAssetContent { get }
    var title: String { get }
    var message: String { get }
    
    func getYouTubeVideoId() -> String?
    func tutorialVideoPlayTapped()
}
