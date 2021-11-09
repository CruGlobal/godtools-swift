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
    
    required init(animationModel: ContentAnimationModelType, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) {
        
        self.animationModel = animationModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
    }
    
    var animationJsonFilepath: String {
        return animationModel.resource ?? ""
    }
    
    var autoPlay: Bool {
        return animationModel.autoPlay
    }
    
    var loop: Bool {
        return animationModel.loop
    }
}
