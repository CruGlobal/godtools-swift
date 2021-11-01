//
//  VideoPlayerViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class VideoPlayerViewModel: VideoPlayerViewModelType {
    
    let youtubeVideoId: String
    
    required init (FlowDelegate: FlowDelegate?, youtubeVideoId: String) {
        
        self.youtubeVideoId = youtubeVideoId
    }
    
    func closeButtonTapped() {
        closeVideoPlayerView()
    }
    
    func videoEnded() {
        closeVideoPlayerView()
    }
    
    private func closeVideoPlayerView() {
        //TODO: Navigate Back to Onboarding-1
    }
}
