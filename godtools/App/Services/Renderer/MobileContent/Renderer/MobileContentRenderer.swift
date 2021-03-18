//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentRenderer {
      
    private let diContainer: MobileContentRendererDiContainer
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let pageNodesParser: MobileContentPageNodesParser = MobileContentPageNodesParser()
    private let pageListenersNotifier: MobileContentPageListenersNotifier
    private let nodeToViewRenderer: MobileContentNodeToViewRenderer
    
    private var pageNodes: [Int: PageNode] = Dictionary()
    
    required init(translationManifest: TranslationManifestData, translationsFileCache: TranslationsFileCache, mobileContentEvents: MobileContentEvents) {
        
        self.diContainer = MobileContentRendererDiContainer()
        self.manifest = MobileContentXmlManifest(translationManifest: translationManifest)
        self.translationsFileCache = translationsFileCache
        self.pageListenersNotifier = MobileContentPageListenersNotifier(mobileContentEvents: mobileContentEvents)
        self.nodeToViewRenderer = MobileContentNodeToViewRenderer(viewFactory: MobileContentRendererViewFactory(diContainer: diContainer))
        
        pageNodesParser.asyncParseAllPageNodes(manifest: manifest, translationsFileCache: translationsFileCache) { [weak self] (page: Int, pageNode: PageNode?, error: Error?) in
            
            if let pageNode = pageNode {
                self?.pageNodes[page] = pageNode
                self?.pageListenersNotifier.addPageListeners(pageNode: pageNode, page: page)
            }
        } completion: { [weak self] (errors: [Error]) in
            
        }
    }
    
    func renderPage(page: Int) -> Result<MobileContentRenderableView, Error> {
        
        let pageNode: PageNode?
        let parseError: Error?
        
        if let cachedPageNode = pageNodes[page] {
            
            pageNode = cachedPageNode
            parseError = nil
        }
        else {
            
            let result: Result<PageNode, Error> = pageNodesParser.parsePageNode(
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                page: page
            )
            
            switch result {
            
            case .success(let parsedPageNode):
                pageNode = parsedPageNode
                parseError = nil
                
            case .failure(let error):
                pageNode = nil
                parseError = error
            }
        }
        
        if let pageNode = pageNode, let renderableView = nodeToViewRenderer.render(node: pageNode) {
            
            return .success(renderableView)
        }
        else if let parseError = parseError {
            
            return .failure(parseError)
        }
        else {
            
            let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
            return .failure(failedToRenderPageError)
        }
    }
}
