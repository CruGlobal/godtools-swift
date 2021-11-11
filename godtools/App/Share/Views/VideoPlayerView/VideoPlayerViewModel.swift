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
    
    private let closeVideoPlayerFlowStep: FlowStep
    private let videoEndedFlowStep: FlowStep
    
    required init (flowDelegate: FlowDelegate, youtubeVideoId: String, closeVideoPlayerFlowStep: FlowStep, videoEndedFlowStep: FlowStep) {
        
        self.flowDelegate = flowDelegate
        
        self.youtubeVideoId = youtubeVideoId
        self.closeVideoPlayerFlowStep = closeVideoPlayerFlowStep
        self.videoEndedFlowStep = videoEndedFlowStep
    }
    
    func closeButtonTapped() {
        
        flowDelegate?.navigate(step: closeVideoPlayerFlowStep)
    }
    
    func videoEnded() {
        
        flowDelegate?.navigate(step: videoEndedFlowStep)
    }
}
