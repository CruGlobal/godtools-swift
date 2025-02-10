//
//  MobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAnimationViewModel: MobileContentViewModel {
    
    enum PlaybackState {
        case pause
        case play
        case stop
    }
    
    private static let eventToggleAnimation: String = "toggleAnimation"
    
    private let animationModel: Animation
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    let animatedViewModel: AnimatedViewModel?
    
    @Published private(set) var playbackState: PlaybackState
    
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
    
    func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                
        let stopAnimationState: PlaybackState = .pause
        let isToggleAnimation: Bool = eventId.name == Self.eventToggleAnimation
        
        if isToggleAnimation {
            
            playbackState = playbackState == .play ? stopAnimationState : .play
        }
        else if animationModel.playListeners.contains(eventId) {
            
            playbackState = .play
        }
        else if animationModel.stopListeners.contains(eventId) {
           
            playbackState = stopAnimationState
        }
        
        return nil
    }
}
