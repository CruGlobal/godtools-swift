//
//  FullScreenVideoViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class FullScreenVideoViewModel: ObservableObject {
    
    private let userDidCloseVideoStep: FlowStep
    private let videoEndedStep: FlowStep
    
    private weak var flowDelegate: FlowDelegate?
    
    let videoId: String
    let videoPlayerParameters: [String: Any]?
    
    init(flowDelegate: FlowDelegate, videoId: String, userDidCloseVideoStep: FlowStep, videoEndedStep: FlowStep) {
        
        self.flowDelegate = flowDelegate
        self.userDidCloseVideoStep = userDidCloseVideoStep
        self.videoEndedStep = videoEndedStep
        self.videoId = videoId
        
        videoPlayerParameters = [
            YouTubePlayerParameterStrings.playsInline.rawValue: 1,
            YouTubePlayerParameterStrings.controls.rawValue: 0
        ]
    }
}

// MARK: - Inputs

extension FullScreenVideoViewModel {
    
    @objc func closeTapped() {
        flowDelegate?.navigate(step: userDidCloseVideoStep)
    }
    
    func videoEnded() {
        flowDelegate?.navigate(step: videoEndedStep)
    }
}
