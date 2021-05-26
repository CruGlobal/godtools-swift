//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentEmbeddedVideoViewModel: MobileContentEmbeddedVideoViewModelType {
    
    private(set) let videoId: String
    
    required init(videoId: String) {
        
        self.videoId = videoId
    }
    
    var youtubePlayerParameters: [String : Any]? {
        return [
            "playsinline": 1
        ]
    }
}
