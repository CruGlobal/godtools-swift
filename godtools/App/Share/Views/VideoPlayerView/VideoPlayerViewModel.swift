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
    
    private let videoEndedFlowStep: FlowStep
    
    required init (flowDelegate: FlowDelegate?, youtubeVideoId: String, videoEndedFlowStep: FlowStep) {
        
        self.flowDelegate = flowDelegate
        
        self.youtubeVideoId = youtubeVideoId
        self.videoEndedFlowStep = videoEndedFlowStep
    }
    
    func videoEnded() {
        
        flowDelegate?.navigate(step: videoEndedFlowStep)
    }
}
