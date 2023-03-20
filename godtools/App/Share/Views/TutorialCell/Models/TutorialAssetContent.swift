//
//  TutorialAssetContent.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

enum TutorialAssetContent {
    
    case animation(viewModel: AnimatedViewModel)
    case customView(customView: UIView)
    case image(image: UIImage)
    case video(youTubeVideoId: String, youTubeVideoParameters: [String: Any]?)
    case none
}
