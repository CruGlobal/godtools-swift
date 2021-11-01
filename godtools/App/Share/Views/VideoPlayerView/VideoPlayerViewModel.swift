//
//  VideoPlayerViewModel.swift
//  godtools
//
//  Created by Robert Eldredge on 11/1/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class VideoPlayerViewModel: VideoPlayerViewModelType {
    
    private weak var flowDelegate: FlowDelegate?
    
    let youtubeVideoId: String
    
    required init (flowDelegate: FlowDelegate?, youtubeVideoId: String) {
        
        self.flowDelegate = flowDelegate
        
        self.youtubeVideoId = youtubeVideoId
    }
    
    func closeButtonTapped() {
        
        flowDelegate?.navigate(step: .closeVideoPlayerTappedFromOnboardingTutorial)
    }
    
    func videoEnded() {
        
        flowDelegate?.navigate(step: .videoEndedOnOnboardingTutorial)
    }
}
