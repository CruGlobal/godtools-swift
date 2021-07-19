//
//  MobileContentXmlNodeRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentXmlNodeRenderer: MobileContentRendererType {
            
    private let xmlParser: MobileContentXmlParser
            
    let resource: ResourceModel
    let language: LanguageModel
    let pageViewFactories: [MobileContentPageViewFactoryType]
    
    required init(resource: ResourceModel, language: LanguageModel, xmlParser: MobileContentXmlParser, pageViewFactories: MobileContentRendererPageViewFactories) {
        
        self.xmlParser = xmlParser
        self.pageViewFactories = pageViewFactories.factories
        self.resource = resource
        self.language = language
    }
    
    var parser: MobileContentParserType {
        return xmlParser
    }
    
    // MARK: - Rendering
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        if let pageNode = xmlParser.getPageNode(page: page) {
                    
            // TODO: Could this get moved to MobileContentRendererType? ~Levi
            return renderPageModel(
                pageModel: pageNode,
                page: page,
                numberOfPages: parser.pageModels.count,
                window: window,
                safeArea: safeArea,
                primaryRendererLanguage: primaryRendererLanguage
            )
        }
        else {
            
            let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
            return .failure(failedToRenderPageError)
        }
    }
        
    func renderPageModel(pageModel: PageModelType, page: Int, numberOfPages: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
    
        guard let pageNode = pageModel as? PageNode else {
            assertionFailure("Expected pageModel: PageModelType to be type PageNode.")
            let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node.  PageModel is not of type PageNode."])
            return .failure(failedToRenderPageError)
        }
        
        let rendererPageModel = MobileContentRendererPageModel(
            pageModel: pageNode,
            page: page,
            isLastPage: page == numberOfPages - 1,
            window: window,
            safeArea: safeArea,
            manifest: parser.manifest,
            resourcesCache: parser.manifestResourcesCache,
            resource: resource,
            language: language,
            pageViewFactories: pageViewFactories,
            primaryRendererLanguage: primaryRendererLanguage
        )
        
        if let renderableView = recurseAndRender(node: pageNode, rendererPageModel: rendererPageModel, containerNode: nil) {
            return .success(renderableView)
        }
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, rendererPageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        let containerNode: MobileContentContainerNode? = (node as? MobileContentContainerNode) ?? containerNode
        
        guard let renderableNode = (node as? MobileContentRenderableModel) else {
            return nil
        }
        
        guard renderableNode.isRenderable else {
            return nil
        }
        
        if let fallbackNode = renderableNode as? ContentFallbackNode {
            var viewToRender: MobileContentView?
            for childNode in fallbackNode.children {
                if let mobileContentView = recurseAndRender(node: childNode, rendererPageModel: rendererPageModel, containerNode: containerNode) {
                    viewToRender = mobileContentView
                    break
                }
            }
            return viewToRender
        }
         
        let mobileContentView: MobileContentView? = getViewFromViewFactory(renderableModel: renderableNode, rendererPageModel: rendererPageModel, containerNode: containerNode)
        
        for childNode in node.children {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(node: childNode, rendererPageModel: rendererPageModel, containerNode: containerNode)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
}
