//
//  MobileContentViewRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 8/24/23.
//  Copyright © 2023 Cru. All rights reserved.
//

import Foundation

class MobileContentViewRenderer {
    
    let pageViewFactories: MobileContentRendererPageViewFactories
    
    init(pageViewFactories: MobileContentRendererPageViewFactories) {
        
        self.pageViewFactories = pageViewFactories
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func recurseAndRender(renderableModel: AnyObject, renderableModelParent: AnyObject?, renderedPageContext: MobileContentRenderedPageContext) -> MobileContentView? {
                   
        let mobileContentView: MobileContentView? = pageViewFactories.viewForRenderableModel(
            renderableModel: renderableModel,
            renderableModelParent: renderableModelParent,
            renderedPageContext: renderedPageContext
        )
                
        let childModels: [AnyObject]
        
        if let renderableModel = renderableModel as? MobileContentRenderableModel {
            childModels = renderableModel.getRenderableChildModels()
        }
        else {
            childModels = Array()
        }
                        
        for childModel in childModels {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(
                renderableModel: childModel,
                renderableModelParent: renderableModel,
                renderedPageContext: renderedPageContext
            )
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
}
