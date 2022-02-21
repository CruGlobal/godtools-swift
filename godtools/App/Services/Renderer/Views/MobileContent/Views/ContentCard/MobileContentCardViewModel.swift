//
//  MobileContentCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation
import GodToolsToolParser

class MobileContentCardViewModel: MobileContentCardViewModelType {
    
    private let contentCard: MultiplatformContentCard
    private let rendererPageModel: MobileContentRendererPageModel
    
    required init(contentCard: MultiplatformContentCard, rendererPageModel: MobileContentRendererPageModel) {
        
        self.contentCard = contentCard
        self.rendererPageModel = rendererPageModel
    }
    
    var events: [EventId] {
        return contentCard.events
    }
    
    var rendererState: State {
        return rendererPageModel.rendererState
    }
}
