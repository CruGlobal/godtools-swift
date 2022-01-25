//
//  ChooseYourOwnAdventurePageViewFactory.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import Foundation

class ChooseYourOwnAdventurePageViewFactory: MobileContentPageViewFactoryType {
    
    var flowDelegate: FlowDelegate?
    
    required init() {
        
    }
    
    func viewForRenderableModel(renderableModel: MobileContentRenderableModel, renderableModelParent: MobileContentRenderableModel?, rendererPageModel: MobileContentRendererPageModel, containerModel: MobileContentRenderableModelContainer?) -> MobileContentView? {
        
        if let contentFlow = renderableModel as? MultiplatformContentFlow {
            
            let viewModel = MobileContentFlowViewModel(
                contentFlow: contentFlow
            )
            
            let view = MobileContentFlowView(viewModel: viewModel, itemSpacing: 16)
            
            return view
        }
        
        return nil
    }
}
