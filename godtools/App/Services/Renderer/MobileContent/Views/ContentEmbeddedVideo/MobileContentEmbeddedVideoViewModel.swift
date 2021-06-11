//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentEmbeddedVideoViewModel: MobileContentEmbeddedVideoViewModelType {
    
    private let videoNode: ContentVideoNode
    
    
    required init(videoNode: ContentVideoNode) {
        self.videoNode = videoNode
    }
    
    var videoId: String {
        guard let id = videoNode.videoId else {
            assertionFailure("videoId should not be nil")
            
            return ""
        }
        
        return id
    }
    
    var youtubePlayerParameters: [String : Any] {
        return [
            "playsinline": 0
        ]
    }
}
