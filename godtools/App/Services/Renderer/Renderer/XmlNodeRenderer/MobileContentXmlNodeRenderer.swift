//
//  MobileContentXmlNodeRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 7/14/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentXmlNodeRenderer: MobileContentRendererType {
    
    enum RendererType {
        case builtFromManifest
        case builtFromProvidedPageNodes
    }
    
    typealias PageListenerEventName = String
    typealias PageNumber = Int
    
    private let mobileContentNodeParser: MobileContentXmlNodeParser = MobileContentXmlNodeParser()
    private let translationsFileCache: TranslationsFileCache
    private let pageViewFactories: [MobileContentPageViewFactoryType]
    private let rendererType: RendererType
    
    private var pageListeners: [PageListenerEventName: PageNumber] = Dictionary()
    
    private(set) var allPageNodes: [PageNode] = Array()
    
    let manifest: MobileContentManifestType
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageModel
    
    var allPageModels: [PageModelType] {
        return allPageNodes
    }
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageModel, manifest: MobileContentManifestType, pageNodes: [PageNode], translationsFileCache: TranslationsFileCache, pageViewFactories: [MobileContentPageViewFactoryType], mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.translationsFileCache = translationsFileCache
        self.manifest = manifest
        self.resourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.resource = resource
        self.language = language

        // pageViewFactories
        let mobileContentPageViewFactory = MobileContentPageViewFactory(
            flowDelegate: flowDelegate,
            mobileContentAnalytics: mobileContentAnalytics,
            fontService: fontService
        )
        var mutablePageViewFactories: [MobileContentPageViewFactoryType] = pageViewFactories
        mutablePageViewFactories.append(mobileContentPageViewFactory)
        self.pageViewFactories = mutablePageViewFactories
        
        if pageNodes.isEmpty {
            
            rendererType = .builtFromManifest
            
            var allPageNodes: [PageNode] = Array()
        
            let manifestPages: [MobileContentManifestPageType] = manifest.pages
            
            var errors: [Error] = Array()
            
            for pageIndex in 0 ..< manifestPages.count {
                
                let result = parsePageNode(
                    manifest: manifest,
                    translationsFileCache: translationsFileCache,
                    page: pageIndex
                )
                
                switch result {
                
                case .success(let pageNode):
                    addPageListeners(pageNode: pageNode, page: pageIndex)
                    allPageNodes.append(pageNode)
                
                case .failure(let error):
                    errors.append(error)
                }
            }
            
            self.allPageNodes = allPageNodes
        }
        else {
            
            rendererType = .builtFromProvidedPageNodes
            
            var allPageNodes: [PageNode] = Array()
            
            for page in 0 ..< pageNodes.count {
                
                let pageNode: PageNode = pageNodes[page]
                
                addPageListeners(pageNode: pageNode, page: page)
                allPageNodes.append(pageNode)
            }
            
            self.allPageNodes = allPageNodes
        }
    }
        
    // MARK: - Page Listeners
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        for event in events {
            if let page = pageListeners[event] {
                return page
            }
        }
        return nil
    }
    
    private func addPageListeners(pageNode: PageNode, page: Int) {
        for listener in pageNode.listeners {
            pageListeners[listener] = page
        }
    }
    
    // MARK: - Rendering
    
    private func getPageNode(page: Int) -> PageNode? {
        
        guard page >= 0 && page < allPageNodes.count else {
            return nil
        }
        
        return allPageNodes[page]
    }
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
        let pageNode: PageNode?
        let parseError: Error?
        
        if let cachedPageNode = getPageNode(page: page) {
            pageNode = cachedPageNode
            parseError = nil
        }
        else {
            
            let result: Result<PageNode, Error> = parsePageNode(
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
        
        if let pageNode = pageNode {
                        
            return renderPageModel(
                pageModel: pageNode,
                page: page,
                numberOfPages: allPageNodes.count,
                window: window,
                safeArea: safeArea,
                primaryRendererLanguage: primaryRendererLanguage
            )
        }
        else if let parseError = parseError {
            
            return .failure(parseError)
        }
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
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
            manifest: manifest,
            resourcesCache: resourcesCache,
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
        
        guard let renderableNode = (node as? MobileContentRenderableNode) else {
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
         
        let mobileContentView: MobileContentView? = getViewFromViewFactory(renderableNode: renderableNode, rendererPageModel: rendererPageModel, containerNode: containerNode)
        
        for childNode in node.children {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(node: childNode, rendererPageModel: rendererPageModel, containerNode: containerNode)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
    
    private func getViewFromViewFactory(renderableNode: MobileContentRenderableNode, rendererPageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        for viewFactory in pageViewFactories {
            
            if let view = viewFactory.viewForRenderableNode(renderableNode: renderableNode, rendererPageModel: rendererPageModel, containerNode: containerNode) {
            
                return view
            }
        }
        
        return nil
    }
    
    // MARK: - Parsing Page Nodes
    
    private func parsePageNode(manifest: MobileContentManifestType, translationsFileCache: TranslationsFileCache, page: Int) -> Result<PageNode, Error> {
        
        let manifestPage: MobileContentManifestPageType = manifest.pages[page]
        let pageXmlCacheLocation: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestPage.src)
                
        switch translationsFileCache.getData(location: pageXmlCacheLocation) {
            
        case .success(let pageXmlData):
            
            guard let xmlData = pageXmlData else {
                let missingXmlData: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Found null xml data in cache."])
                return .failure(missingXmlData)
            }
            
            guard let pageNode = mobileContentNodeParser.parse(xml: xmlData, delegate: nil) as? PageNode else {
                let failedToParsePageNode: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to parse pageNode from xmlData."])
                return .failure(failedToParsePageNode)
            }
            
            return .success(pageNode)
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
