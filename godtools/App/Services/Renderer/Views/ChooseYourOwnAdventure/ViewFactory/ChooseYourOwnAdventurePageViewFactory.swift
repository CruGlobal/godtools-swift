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
        
        if let contentModel = renderableModel as? ContentModelType {
            
        }
        
        return nil
    }
}
