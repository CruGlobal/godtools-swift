//
//  MobileContentContentPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class MobileContentContentPageViewModel: MobileContentPageViewModel, MobileContentContentPageViewModelType {
    
    private let contentPage: MultiplatformContentPage
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(flowDelegate: FlowDelegate, contentPage: MultiplatformContentPage, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType) {
        
        self.contentPage = contentPage
        self.rendererPageModel = rendererPageModel
        
        super.init(flowDelegate: flowDelegate, pageModel: contentPage, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
}
