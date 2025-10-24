//
//  MobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

class MobileContentAnimationViewModel: MobileContentViewModel {
            
    private let animationModel: Animation
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    let animatedViewModel: AnimatedViewModel?
    
    @Published private(set) var playbackState: MobileContentAnimationPlaybackState
    
    init(animationModel: Animation, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentRendererAnalytics) {
        
        self.animationModel = animationModel
        self.mobileContentAnalytics = mobileContentAnalytics
                
        if let resource = animationModel.resource {
            
            let animationfileResult: Result<URL, Error> = renderedPageContext.resourcesCache.getFile(resource: resource)
            
            switch animationfileResult {
            
            case .success(let fileUrl):
                animatedViewModel = AnimatedViewModel(
                    animationDataResource: .deviceFileManagerfilepathJsonFile(filepath: fileUrl.path),
                    autoPlay: animationModel.autoPlay,
                    loop: animationModel.loop
                )
            
            case .failure( _):
                animatedViewModel = nil
            }
            
            playbackState = animationModel.autoPlay ? .play : .stop
        }
        else {
            animatedViewModel = nil
            playbackState = .stop
        }
        
        super.init(baseModel: animationModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}

extension MobileContentAnimationViewModel {
    
    func animationPlaybackDidComplete(animationIsPlaying: Bool) {
        if !animationIsPlaying {
            playbackState = .pause
        }
    }
    
    func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                
        if animationModel.playListeners.contains(eventId) && playbackState != .play {
            playbackState = .play
        }
        else if animationModel.stopListeners.contains(eventId) && playbackState == .play {
            playbackState = .pause
        }
        
        return nil
    }
}
