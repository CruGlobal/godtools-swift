//
//  MobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentAnimationViewModel: MobileContentAnimationViewModelType {
    
    private let animationModel: Animation
    private let renderedPageContext: MobileContentRenderedPageContext
    
    let animatedViewModel: AnimatedViewModelType?
    
    required init(animationModel: Animation, renderedPageContext: MobileContentRenderedPageContext) {
        
        self.animationModel = animationModel
        self.renderedPageContext = renderedPageContext
                
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
    }
    
    func animationTapped() {
        
    }
}
