//
//  MobileContentEmbeddedVideoViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 5/26/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentEmbeddedVideoViewModel: MobileContentEmbeddedVideoViewModelType {
    
    private let videoModel: ContentVideoModelType
    
    required init(videoModel: ContentVideoModelType) {
        
        self.videoModel = videoModel
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
