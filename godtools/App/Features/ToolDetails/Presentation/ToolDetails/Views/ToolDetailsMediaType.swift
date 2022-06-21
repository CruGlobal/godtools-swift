//
//  ToolDetailsMediaType.swift
//  godtools
//
//  Created by Levi Eggert on 6/10/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import SwiftUI

enum ToolDetailsMediaType {
    
    case animation(viewModel: AnimatedViewModelType)
    case image(image: Image)
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
