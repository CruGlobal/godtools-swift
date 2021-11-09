//
//  MobileContentAnimationViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentAnimationViewModel: MobileContentAnimationViewModelType {
    
    private let animationModel: ContentAnimationModelType
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    
    let animatedViewModel: AnimatedViewModelType
    
    required init(animationModel: ContentAnimationModelType, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) {
        
        self.animationModel = animationModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        
        self.animatedViewModel = AnimatedViewModel(
            animationDataResource: .filepathJsonFile(filepath: animationModel.resource ?? ""),
            autoPlay: animationModel.autoPlay,
            loop: animationModel.loop
        )
    }
}
