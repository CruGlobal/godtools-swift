//
//  MobileContentNodeToViewRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 3/18/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentNodeToViewRenderer {
    
    private let viewFactory: MobileContentRendererViewFactory
    
    required init(viewFactory: MobileContentRendererViewFactory) {
        
        self.viewFactory = viewFactory
    }
    
    func render(node: MobileContentXmlNode) -> MobileContentRenderableView? {
                        
        return recurseAndRender(node: node, viewFactory: viewFactory)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, viewFactory: MobileContentRendererViewFactory) -> MobileContentRenderableView? {
        
        guard let renderableNode = (node as? MobileContentRenderableNode) else {
            return nil
        }
        
        guard renderableNode.isRenderable else {
            return nil
        }
        
        if let fallbackNode = renderableNode as? ContentFallbackNode {
            var viewToRender: MobileContentRenderableView?
            for childNode in fallbackNode.children {
                if let renderableView = recurseAndRender(node: childNode, viewFactory: viewFactory) {
                    viewToRender = renderableView
                    break
                }
            }
            return viewToRender
        }
            
        let renderableView: MobileContentRenderableView? = viewFactory.viewForRenderableNode(renderableNode: renderableNode)
        
        for childNode in node.children {
            
            let childRenderableView: MobileContentRenderableView? = recurseAndRender(node: childNode, viewFactory: viewFactory)
            
            if let childRenderableView = childRenderableView, let renderableView = renderableView {
                renderableView.addRenderableView(renderableView: childRenderableView)
            }
        }
        
        renderableView?.finishedRenderingChildren()
        
        return renderableView
    }
}
