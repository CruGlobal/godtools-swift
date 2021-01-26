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
    
    private let node: MobileContentXmlNode
    private let viewFactory: MobileContentRendererViewFactoryType
    
    //private let buttonEvents: MobileContentButtonEvents
    //private let linkEvents: MobileContentLinkEvents
    //private let imageEvents: MobileContentImageEvents
    //private weak var delegate: MobileContentRendererDelegate?
    
    required init(node: MobileContentXmlNode, viewFactory: MobileContentRendererViewFactoryType) {
        
        self.node = node
        self.viewFactory = viewFactory
        
        //buttonEvents = MobileContentButtonEvents(mobileContentEvents: mobileContentEvents, mobileContentAnalytics: mobileContentAnalytics)
        //linkEvents = MobileContentLinkEvents(mobileContentEvents: mobileContentEvents, mobileContentAnalytics: mobileContentAnalytics)
        //imageEvents = MobileContentImageEvents(mobileContentEvents: mobileContentEvents)
    }
    
    private func resetForNewRender() {
        //buttonEvents.removeAllButtonEvents()
        //linkEvents.removeAllLinkEvents()
        //imageEvents.removeAllImageEvents()
    }
    
    func render() -> MobileContentRenderableView? {
        
        resetForNewRender()
        
        //self.delegate = delegate
        
        return recurseAndRender(node: node, viewFactory: viewFactory)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, viewFactory: MobileContentRendererViewFactoryType) -> MobileContentRenderableView? {
        
        guard let renderableNode = (node as? MobileContentRenderableNode) else {
            return nil
        }
        
        guard renderableNode.isRenderable else {
            return nil
        }
    
        let renderableView: MobileContentRenderableView? = viewFactory.viewForRenderableNode(renderableNode: renderableNode)
        
        if let buttonNode = renderableNode as? ContentButtonNode, let button = renderableView?.view as? UIButton {
            //buttonEvents.addButtonEvent(button: button, buttonNode: buttonNode)
        }
        else if let imageNode = renderableNode as? ContentImageNode, let imageView = renderableView?.view as? UIImageView {
            //imageEvents.addImageEvent(image: imageView, imageNode: imageNode)
        }
        else if let linkNode = renderableNode as? ContentLinkNode, let button = renderableView?.view as? UIButton {
            //linkEvents.addLinkEvent(button: button, linkNode: linkNode)
        }
        
        for childNode in node.children {
            
            let childRenderableView: MobileContentRenderableView? = recurseAndRender(node: childNode, viewFactory: viewFactory)
            
            if let childRenderableView = childRenderableView, let renderableView = renderableView {
                renderableView.addRenderableView(renderableView: childRenderableView)
            }
        }
        
        return renderableView
    }
}
