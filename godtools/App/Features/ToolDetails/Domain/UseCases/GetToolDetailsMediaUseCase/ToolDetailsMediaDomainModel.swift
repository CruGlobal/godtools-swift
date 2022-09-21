//
//  ToolDetailsMediaDomainModel.swift
//  godtools
//
//  Created by Levi Eggert on 8/4/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import SwiftUI

enum ToolDetailsMediaDomainModel {
    
    case animation(viewModel: AnimatedViewModel)
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
