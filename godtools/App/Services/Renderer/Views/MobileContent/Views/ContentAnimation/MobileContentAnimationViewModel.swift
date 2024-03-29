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
    
    private let animationModel: Animation
    
    let mobileContentAnalytics: MobileContentRendererAnalytics
    let animatedViewModel: AnimatedViewModel?
    
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
        }
        else {
            animatedViewModel = nil
        }
        
        super.init(baseModel: animationModel, renderedPageContext: renderedPageContext, mobileContentAnalytics: mobileContentAnalytics)
    }
}
