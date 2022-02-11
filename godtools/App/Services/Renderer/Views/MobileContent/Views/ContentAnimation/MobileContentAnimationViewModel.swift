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
    private let rendererPageModel: MobileContentRendererPageModel
    private let containerModel: MobileContentRenderableModelContainer?
    
    let animatedViewModel: AnimatedViewModelType
    
    required init(animationModel: Animation, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) {
        
        self.animationModel = animationModel
        self.rendererPageModel = rendererPageModel
        self.containerModel = containerModel
        
        let animationFilepath: String
        
        let animationfileResult: Result<URL, Error> = rendererPageModel.resourcesCache.getFile(fileName: animationModel.resource?.name ?? "")
        
        switch animationfileResult {
        case .success(let fileUrl):
            animationFilepath = fileUrl.path
        case .failure(let error):
            animationFilepath = ""
        }
        
        self.animatedViewModel = AnimatedViewModel(
            animationDataResource: .filepathJsonFile(filepath: animationFilepath),
            autoPlay: animationModel.autoPlay,
            loop: animationModel.loop
        )
    }
    
    func animationTapped() {
        
    }
}
