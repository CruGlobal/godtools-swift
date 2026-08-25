//
//  LegacyMobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsShared

final class LegacyMobileContentAnimationViewModel: LegacyMobileContentViewModel {
            
    private let animationModel: Animation
    
    private(set) var animatedViewModel: AnimatedViewModel?
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    
    @Published private(set) var playbackState: MobileContentAnimationPlaybackState = .stop
    
    init(
        animationModel: Animation,
        renderedPageContext: MobileContentRenderedPageContext,
        mobileContentAnalytics: MobileContentRendererAnalytics
    ) {
        
        self.animationModel = animationModel
        self.mobileContentAnalytics = mobileContentAnalytics
                
        super.init(
            baseModel: animationModel,
            renderedPageContext: renderedPageContext,
            mobileContentAnalytics: mobileContentAnalytics
        )
        
        loadAnimation()
    }

    private func loadAnimation() {
        
        if let resource = animationModel.resource, let location = resource.toSHA256FileLocation() {
            
            do {
                
                let fileUrl = try renderedPageContext.resourcesFileCache.getFile(location: location)
                
                animatedViewModel = AnimatedViewModel(
                    animationDataResource: .deviceFileManagerfilepathJsonFile(filepath: fileUrl.path),
                    autoPlay: animationModel.autoPlay,
                    loop: animationModel.loop
                )
                
            }
            catch _ {
                animatedViewModel = nil
            }
            
            playbackState = animationModel.autoPlay ? .play : .stop
        }
        else {
            animatedViewModel = nil
            playbackState = .stop
        }
    }
}

extension LegacyMobileContentAnimationViewModel {
    
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
