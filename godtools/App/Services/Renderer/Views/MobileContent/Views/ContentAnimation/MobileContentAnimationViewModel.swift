//
//  MobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAnimationViewModel: MobileContentViewModel, ClickableMobileContentViewModel {
    
    private let animationModel: Animation
    private let renderedPageContext: MobileContentRenderedPageContext
    private let mobileContentAnalytics: MobileContentAnalytics
    
    let animatedViewModel: AnimatedViewModelType?
    
    init(animationModel: Animation, renderedPageContext: MobileContentRenderedPageContext, mobileContentAnalytics: MobileContentAnalytics) {
        
        self.animationModel = animationModel
        self.renderedPageContext = renderedPageContext
        self.mobileContentAnalytics = mobileContentAnalytics
                
        if let resource = animationModel.resource {
            
            let animationfileResult: Result<URL, Error> = renderedPageContext.resourcesCache.getFile(resource: resource)
            
            switch animationfileResult {
            
            case .success(let fileUrl):
                animatedViewModel = AnimatedViewModel(
                    animationDataResource: .filepathJsonFile(filepath: fileUrl.path),
                    autoPlay: animationModel.autoPlay,
                    loop: animationModel.loop
                )
            
            case .failure(let error):
                animatedViewModel = nil
            }
        }
        else {
            animatedViewModel = nil
        }
        
        super.init(baseModel: animationModel)
    }
    
    var animationEvents: [EventId] {
        return animationModel.events
    }
    
    var rendererState: State {
        return renderedPageContext.rendererState
    }
    
    func getClickableUrl() -> URL? {
        return getClickableUrl(model: animationModel)
    }
}

// MARK: - Inputs

extension MobileContentAnimationViewModel {
    
    func animationTapped() {
        trackClickableEvents(model: animationModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
