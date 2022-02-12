//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentEmbeddedVideoViewModel: MobileContentEmbeddedVideoViewModelType {
    
    private let videoModel: Video
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(videoModel: Video, rendererPageModel: MobileContentRendererPageModel) {
        
        self.videoModel = videoModel
        self.rendererPageModel = rendererPageModel
    }
    
    var videoId: String {
        
        guard let id = videoModel.videoId else {
            assertionFailure("videoId should not be nil")
            
            return ""
        }
        
        return id
    }
    
    var youtubePlayerParameters: [String : Any] {
        
        let playsInFullScreen = 0
        
        return [
            "playsinline": playsInFullScreen
        ]
    }
}
