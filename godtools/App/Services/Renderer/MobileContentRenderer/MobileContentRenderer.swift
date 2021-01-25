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
    
    private let buttonEvents: MobileContentButtonEvents
    private let linkEvents: MobileContentLinkEvents
    private let imageEvents: MobileContentImageEvents
    
    private weak var delegate: MobileContentRendererDelegate?
    
    required init(mobileContentEvents: MobileContentEvents, mobileContentAnalytics: MobileContentAnalytics) {
        
        buttonEvents = MobileContentButtonEvents(mobileContentEvents: mobileContentEvents, mobileContentAnalytics: mobileContentAnalytics)
        linkEvents = MobileContentLinkEvents(mobileContentEvents: mobileContentEvents, mobileContentAnalytics: mobileContentAnalytics)
        imageEvents = MobileContentImageEvents(mobileContentEvents: mobileContentEvents)
    }
    
    private func resetForNewRender() {
        buttonEvents.removeAllButtonEvents()
        linkEvents.removeAllLinkEvents()
        imageEvents.removeAllImageEvents()
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
        
        if let buttonNode = renderableNode as? ContentButtonNode, let button = renderableView?.view as? UIButton {
            buttonEvents.addButtonEvent(button: button, buttonNode: buttonNode)
        }
        else if let imageNode = renderableNode as? ContentImageNode, let imageView = renderableView?.view as? UIImageView {
            imageEvents.addImageEvent(image: imageView, imageNode: imageNode)
        }
        else if let linkNode = renderableNode as? ContentLinkNode, let button = renderableView?.view as? UIButton {
            linkEvents.addLinkEvent(button: button, linkNode: linkNode)
        }
        
        for childNode in node.children {
            
            let childRenderableView: MobileContentRenderableView? = recurseAndRender(node: childNode, delegate: delegate)
            
            if let childRenderableView = childRenderableView, let renderableView = renderableView {
                renderableView.addRenderableView(renderableView: childRenderableView)
            }
        }
        
        return renderableView
    }
}
