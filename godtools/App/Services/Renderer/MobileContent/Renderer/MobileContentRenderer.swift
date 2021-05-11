//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRenderer: MobileContentRendererType {
      
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
    
    private var allPageNodes: [PageNode] = Array()
    private var pageListeners: [PageListenerEventName: PageNumber] = Dictionary()
    private var didFinishLoadingAllPageNodes: Bool = false
    
    let manifest: MobileContentXmlManifest
    let resourcesCache: ManifestResourcesCache
    let resource: ResourceModel
    let language: LanguageModel
    let pages: ObservableValue<[PageNode]> = ObservableValue(value: [])
    
    required init(resource: ResourceModel, language: LanguageModel, manifest: MobileContentXmlManifest, pageNodes: [PageNode], translationsFileCache: TranslationsFileCache, pageViewFactories: [MobileContentPageViewFactoryType], mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.translationsFileCache = translationsFileCache
        self.manifest = manifest
        self.resourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.resource = resource
        self.language = language

        // pageViewFactories
        let mobileContentPageViewFactory = MobileContentPageViewFactory(
            mobileContentAnalytics: mobileContentAnalytics,
            fontService: fontService
        )
        var mutablePageViewFactories: [MobileContentPageViewFactoryType] = pageViewFactories
        mutablePageViewFactories.append(mobileContentPageViewFactory)
        self.pageViewFactories = mutablePageViewFactories
        
        if pageNodes.isEmpty {
            
            rendererType = .builtFromManifest
            
            asyncParseAllPageNodes(manifest: manifest, translationsFileCache: translationsFileCache) { [weak self] (page: Int, pageNode: PageNode?, error: Error?) in
                
                if let pageNode = pageNode {
                    
                    self?.addPageNodeAndPageListeners(
                        page: page,
                        pageNode: pageNode
                    )
                }
            } completion: { [weak self] (errors: [Error]) in
                DispatchQueue.main.async { [weak self] in
                    self?.handleCompletedLoadingAllPageNodes()
                }
            }
        }
        else {
            
            rendererType = .builtFromProvidedPageNodes
            
            for page in 0 ..< pageNodes.count {
                addPageNodeAndPageListeners(
                    page: page,
                    pageNode: pageNodes[page]
                )
            }
            
            handleCompletedLoadingAllPageNodes()
        }
    }
    
    private func addPageNodeAndPageListeners(page: Int, pageNode: PageNode) {
        
        allPageNodes.append(pageNode)
        addPageListeners(pageNode: pageNode, page: page)
    }
    
    private func handleCompletedLoadingAllPageNodes() {
        
        didFinishLoadingAllPageNodes = true
        
        pages.accept(value: allPageNodes)
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
    
    func getPageNode(page: Int) -> PageNode? {
        
        guard page >= 0 && page < allPageNodes.count else {
            return nil
        }
        
        return allPageNodes[page]
    }
    
    func renderPageFromAllPageNodes(page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
        
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
            
            let numberOfPages: Int
            
            if didFinishLoadingAllPageNodes {
                numberOfPages = allPageNodes.count
            }
            else {
                switch rendererType {
                case .builtFromManifest:
                    numberOfPages = manifest.pages.count
                case .builtFromProvidedPageNodes:
                    numberOfPages = allPageNodes.count
                }
            }
            
            let isLastPage: Bool = page == numberOfPages - 1
            
            let pageModel = MobileContentRendererPageModel(
                pageNode: pageNode,
                page: page,
                isLastPage: isLastPage,
                window: window,
                safeArea: safeArea,
                manifest: manifest,
                resourcesCache: resourcesCache,
                resource: resource,
                language: language,
                pageViewFactories: pageViewFactories,
                primaryRendererLanguage: primaryRendererLanguage
            )
            
            if let renderableView = recurseAndRender(node: pageNode, pageModel: pageModel, containerNode: nil) {
                return .success(renderableView)
            }
        }
        else if let parseError = parseError {
            
            return .failure(parseError)
        }
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
    }
    
    func renderPageFromPageNodes(pageNodes: [PageNode], page: Int, window: UIViewController, safeArea: UIEdgeInsets, primaryRendererLanguage: LanguageModel) -> Result<MobileContentView, Error> {
                
        guard page >= 0 && page < pageNodes.count else {
            let outOfBoundsError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Page is out of array bounds. page: \(page)  pageNodes.count: \(pageNodes.count)"])
            return .failure(outOfBoundsError)
        }
        
        let pageNode: PageNode = pageNodes[page]
        let isLastPage: Bool = page == pageNodes.count - 1
        
        let pageModel = MobileContentRendererPageModel(
            pageNode: pageNode,
            page: page,
            isLastPage: isLastPage,
            window: window,
            safeArea: safeArea,
            manifest: manifest,
            resourcesCache: resourcesCache,
            resource: resource,
            language: language,
            pageViewFactories: pageViewFactories,
            primaryRendererLanguage: primaryRendererLanguage
        )
        
        if let renderableView = recurseAndRender(node: pageNode, pageModel: pageModel, containerNode: nil) {
            return .success(renderableView)
        }
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, pageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
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
                if let mobileContentView = recurseAndRender(node: childNode, pageModel: pageModel, containerNode: containerNode) {
                    viewToRender = mobileContentView
                    break
                }
            }
            return viewToRender
        }
         
        let mobileContentView: MobileContentView? = getViewFromViewFactory(renderableNode: renderableNode, pageModel: pageModel, containerNode: containerNode)
        
        for childNode in node.children {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(node: childNode, pageModel: pageModel, containerNode: containerNode)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
    
    private func getViewFromViewFactory(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel, containerNode: MobileContentContainerNode?) -> MobileContentView? {
        
        for viewFactory in pageViewFactories {
            
            if let view = viewFactory.viewForRenderableNode(renderableNode: renderableNode, pageModel: pageModel, containerNode: containerNode) {
            
                return view
            }
        }
        
        return nil
    }
    
    // MARK: - Parsing Page Nodes
    
    private func asyncParseAllPageNodes(manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, didParsePageNode: @escaping ((_ page: Int, _ pageNode: PageNode?, _ error: Error?) -> Void), completion: @escaping ((_ errors: [Error]) -> Void)) {
        
        let manifestPages: [MobileContentXmlManifestPage] = manifest.pages
        
        var errors: [Error] = Array()
        
        DispatchQueue.global().async { [weak self] in
            
            guard let toolPagesNodeParser = self else {
                return
            }
            
            for pageIndex in 0 ..< manifestPages.count {
                
                let result = toolPagesNodeParser.parsePageNode(
                    manifest: manifest,
                    translationsFileCache: translationsFileCache,
                    page: pageIndex
                )
                
                switch result {
                
                case .success(let pageNode):
                    didParsePageNode(pageIndex, pageNode, nil)
                
                case .failure(let error):
                    didParsePageNode(pageIndex, nil, error)
                    errors.append(error)
                }
            }
            
            completion(errors)
        }
    }
    
    private func parsePageNode(manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, page: Int) -> Result<PageNode, Error> {
        
        let manifestPage: MobileContentXmlManifestPage = manifest.pages[page]
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
