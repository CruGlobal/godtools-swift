//
//  ToolDetailBanner.swift
//  godtools
//
//  Created by Levi Eggert on 5/9/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

enum ToolDetailBanner {
    
    case animation(viewModel: AnimatedViewModelType)
    case image(image: UIImage)
    case youtube(videoId: String, playerParameters: [String: Any]?)
    case empty
    
    func getYoutubeVideoId() -> String? {
        switch self {
        case .youtube(let videoId, _):
            return videoId
        default:
            return nil
        }
    }
}
