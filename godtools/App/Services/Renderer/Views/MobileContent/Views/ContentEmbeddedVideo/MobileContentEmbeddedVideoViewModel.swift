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
    
    init(videoModel: Video, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.videoModel = videoModel
        
        super.init(baseModel: videoModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
    
    private func getTrackElapsedTimeCacheKey() -> String {
        
        let key: String = "videoElapsedTimeCacheKey"
        
        guard let id = videoModel.videoId else {
            return key
        }
        
        return id + key
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

extension MobileContentEmbeddedVideoViewModel {
    
    func getLastTrackedElapsedTime() -> Float? {
        
        let key: String = getTrackElapsedTimeCacheKey()
        
        guard let elapsedTime = renderedPageContext.pageViewDataCache.getValue(key: key) as? Float else {
            return nil
        }
        
        return elapsedTime
    }
    
    func trackElapsedTime(elapsedTime: Float) {
        
        guard elapsedTime > 0 else {
            return
        }
        
        let key: String = getTrackElapsedTimeCacheKey()
        
        renderedPageContext.pageViewDataCache.storeValue(
            key: key,
            value: elapsedTime
        )
    }
}
