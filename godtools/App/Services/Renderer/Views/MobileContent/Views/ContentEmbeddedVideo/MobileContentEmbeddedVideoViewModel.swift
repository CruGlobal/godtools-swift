//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentEmbeddedVideoViewModel: MobileContentViewModel {
    
    private let videoModel: Video
    private let renderedPageContext: MobileContentRenderedPageContext
    
    init(videoModel: Video, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.videoModel = videoModel
        self.renderedPageContext = renderedPageContext
        
        super.init(baseModel: videoModel)
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
            Strings.YoutubePlayerParameters.playsInline.rawValue: playsInFullScreen
        ]
    }
}
