//
//  FullScreenVideoViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 2/1/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

@MainActor
class FullScreenVideoViewModel: ObservableObject {
    
    private let userDidCloseVideoStep: AppFlowStep
    private let videoEndedStep: AppFlowStep
    
    private weak var flowDelegate: FlowDelegate?
    
    let videoId: String
    let videoPlayerParameters: [String: Any]?
    
    init(flowDelegate: FlowDelegate, videoId: String, videoPlayerParameters: [String: Any]?, userDidCloseVideoStep: AppFlowStep, videoEndedStep: AppFlowStep) {
        
        self.flowDelegate = flowDelegate
        self.userDidCloseVideoStep = userDidCloseVideoStep
        self.videoEndedStep = videoEndedStep
        self.videoId = videoId
        self.videoPlayerParameters = FullScreenVideoViewModel.buildVideoPlayerParameters(fromParameters: videoPlayerParameters)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private static func buildVideoPlayerParameters(fromParameters: [String: Any]?) -> [String: Any] {
        
        var videoPlayerParameters: [String: Any] = fromParameters ?? Dictionary()
        
        let playsInlineKey: String = YoutubePlayerParameters.playsInline.rawValue
        let disablesFullScreen: Int = 1
        
        if videoPlayerParameters[playsInlineKey] == nil {
            videoPlayerParameters[playsInlineKey] = disablesFullScreen
        }
        
        return videoPlayerParameters
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
