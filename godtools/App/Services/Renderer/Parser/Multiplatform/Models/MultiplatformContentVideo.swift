//
//  MultiplatformContentVideo.swift
//  godtools
//
//  Created by Levi Eggert on 7/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MultiplatformContentVideo: ContentVideoModelType {
    
    private let video: Video
    
    required init(video: Video) {
        
        self.video = video
    }
    
    var provider: MobileContentVideoProvider {
        
        switch video.provider {
        case .youtube:
            return .youtube
        case .unknown:
            return .unknown
        default:
            assertionFailure("Returning video.provider for unsupported enum value.  Ensure all enum values are supported for video.provider.")
            return .unknown
        }
    }
    
    var videoId: String? {
        return video.videoId
    }
}

// MARK: - MobileContentRenderableModel

extension MultiplatformContentVideo {
    
    var restrictTo: String? {
        return nil
    }
    
    var version: String? {
        return nil
    }
    
    var modelContentIsRenderable: Bool {
        return true
    }
    
    func getRenderableChildModels() -> [MobileContentRenderableModel] {
        return Array()
    }
}
