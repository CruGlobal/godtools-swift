//
//  TrainingPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 3/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class TrainingPageViewModel: MobileContentPageViewModel, TrainingPageViewModelType {
    
    private let pageModel: Page
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType) {
        
        self.pageModel = pageModel
        self.rendererPageModel = rendererPageModel
        
        super.init(flowDelegate: flowDelegate, pageModel: pageModel, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: true)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: Page, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
}
