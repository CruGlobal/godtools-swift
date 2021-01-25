//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererDelegate: class {
    
    func mobileContentRendererViewForRenderableNode(renderer: MobileContentRenderer, renderableNode: MobileContentRenderableNode) -> MobileContentRenderableView?
}

class MobileContentRenderer {
    
    private weak var delegate: MobileContentRendererDelegate?
    
    required init() {
        
    }
    
    private func resetForNewRender() {

    }
    
    func render(node: MobileContentXmlNode, delegate: MobileContentRendererDelegate) -> MobileContentRenderableView? {
        
        resetForNewRender()
        
        self.delegate = delegate
        
        return recurseAndRender(node: node, delegate: delegate)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, delegate: MobileContentRendererDelegate) -> MobileContentRenderableView? {
        
        guard let renderableNode = (node as? MobileContentRenderableNode) else {
            return nil
        }
        
        guard renderableNode.isRenderable else {
            return nil
        }
    
        let renderableView: MobileContentRenderableView? = delegate.mobileContentRendererViewForRenderableNode(
            renderer: self,
            renderableNode: renderableNode
        )
        
        for childNode in node.children {
            
            let childRenderableView: MobileContentRenderableView? = recurseAndRender(node: childNode, delegate: delegate)
            
            if let childRenderableView = childRenderableView, let renderableView = renderableView {
                renderableView.addRenderableView(renderableView: childRenderableView)
            }
        }
        
        return renderableView
    }
}
