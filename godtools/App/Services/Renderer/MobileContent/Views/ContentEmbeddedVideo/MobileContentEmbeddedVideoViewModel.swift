//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentEmbeddedVideoViewModel: MobileContentEmbeddedVideoViewModelType {
    
    let videoId: String?
    //let provider: String?
    
    required init(videoNode: ContentVideoNode) {
        
        self.videoId = videoNode.videoId
        //self.provider = videoNode.provider
    }
    
    var youtubePlayerParameters: [String : Any] {
        return [
            "playsinline": 1
        ]
    }
}
