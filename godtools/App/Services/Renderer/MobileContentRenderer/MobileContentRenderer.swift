//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

protocol MobileContentRendererDelegate: class {
    
    func mobileContentRendererViewForRenderableContainerNode(renderer: MobileContentRenderer, renderableContainerNode: MobileContentRenderableContainerNode) -> MobileContentRenderableContainerView?
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
        
        let renderableContainerView: MobileContentRenderableContainerView?
        let renderableView: MobileContentRenderableView?
        
        if let renderableContainerNode = renderableNode as? MobileContentRenderableContainerNode {
            
            renderableContainerView = delegate.mobileContentRendererViewForRenderableContainerNode(
                renderer: self,
                renderableContainerNode: renderableContainerNode
            )
            
            renderableView = nil
        }
        else {
            
            renderableContainerView = nil
            
            renderableView = delegate.mobileContentRendererViewForRenderableNode(
                renderer: self,
                renderableNode: renderableNode
            )
        }
        
        for childNode in node.children {
            
            let childRenderableView: MobileContentRenderableView? = recurseAndRender(node: childNode, delegate: delegate)
            
            if let childRenderableView = childRenderableView, let renderableContainerView = renderableContainerView {
                renderableContainerView.addRenderableView(renderableView: childRenderableView)
            }
        }
        
        return renderableContainerView ?? renderableView
    }
}
