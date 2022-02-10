//
//  MobileContentCardCollectionPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardCollectionPageViewModel: MobileContentPageViewModel, MobileContentCardCollectionPageViewModelType {
    
    private let cardCollectionPage: MultiplatformCardCollectionPage
    private let rendererPageModel: MobileContentRendererPageModel
        
    required init(flowDelegate: FlowDelegate, cardCollectionPage: MultiplatformCardCollectionPage, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType) {
        
        self.cardCollectionPage = cardCollectionPage
        self.rendererPageModel = rendererPageModel
        
        super.init(flowDelegate: flowDelegate, pageModel: cardCollectionPage, rendererPageModel: rendererPageModel, deepLinkService: deepLinkService, hidesBackgroundImage: false)
    }
    
    required init(flowDelegate: FlowDelegate, pageModel: PageModelType, rendererPageModel: MobileContentRendererPageModel, deepLinkService: DeepLinkingServiceType, hidesBackgroundImage: Bool) {
        fatalError("init(flowDelegate:pageModel:rendererPageModel:deepLinkService:hidesBackgroundImage:) has not been implemented")
    }
}
