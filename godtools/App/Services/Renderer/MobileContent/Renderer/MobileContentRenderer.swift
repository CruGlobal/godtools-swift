//
//  MobileContentRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 1/24/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentRenderer {
      
    typealias PageListenerEventName = String
    typealias PageNumber = Int
    
    private let mobileContentNodeParser: MobileContentXmlNodeParser = MobileContentXmlNodeParser()
    private let translationsFileCache: TranslationsFileCache
    private let pageViewFactories: [MobileContentPageViewFactoryType]
    
    private(set) var pageNodes: [Int: PageNode] = Dictionary()
    private(set) var pageListeners: [PageListenerEventName: PageNumber] = Dictionary()
    
    let manifest: MobileContentXmlManifest
    let resourcesCache: ManifestResourcesCache
    let language: LanguageModel
    
    required init(language: LanguageModel, translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache, pageViewFactory: MobileContentPageViewFactoryType, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService) {
        
        self.translationsFileCache = translationsFileCache
        self.manifest = MobileContentXmlManifest(translationManifest: translationManifestData)
        self.resourcesCache = ManifestResourcesCache(manifest: manifest, translationsFileCache: translationsFileCache)
        self.language = language
        self.pageViewFactories = [
            pageViewFactory,
            MobileContentPageViewFactory(
                mobileContentAnalytics: mobileContentAnalytics,
                fontService: fontService
            )
        ]
        
        asyncParseAllPageNodes(manifest: manifest, translationsFileCache: translationsFileCache) { [weak self] (page: Int, pageNode: PageNode?, error: Error?) in
            
            if let pageNode = pageNode {
                self?.pageNodes[page] = pageNode
                self?.addPageListeners(pageNode: pageNode, page: page)
            }
        } completion: { [weak self] (errors: [Error]) in
            
        }
    }
    
    var numberOfPages: Int {
        return manifest.pages.count
    }
    
    // MARK: - Page Listeners
    
    private func addPageListeners(pageNode: PageNode, page: Int) {
        for listener in pageNode.listeners {
            pageListeners[listener] = page
        }
    }
    
    // MARK: - Rendering
    
    func renderPage(page: Int, window: UIViewController, safeArea: UIEdgeInsets) -> Result<MobileContentView, Error> {
        
        let pageNode: PageNode?
        let parseError: Error?
        
        if let cachedPageNode = pageNodes[page] {
            
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
            
            let pageModel = MobileContentRendererPageModel(
                pageNode: pageNode,
                page: page,
                numberOfPages: numberOfPages,
                window: window,
                safeArea: safeArea,
                manifest: manifest,
                resourcesCache: resourcesCache,
                language: language
            )
            
            if let renderableView = recurseAndRender(node: pageNode, pageModel: pageModel) {
                return .success(renderableView)
            }
        }
        else if let parseError = parseError {
            
            return .failure(parseError)
        }
        
        let failedToRenderPageError: Error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to render page node."])
        return .failure(failedToRenderPageError)
    }
    
    private func recurseAndRender(node: MobileContentXmlNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        guard let renderableNode = (node as? MobileContentRenderableNode) else {
            return nil
        }
        
        guard renderableNode.isRenderable else {
            return nil
        }
        
        if let fallbackNode = renderableNode as? ContentFallbackNode {
            var viewToRender: MobileContentView?
            for childNode in fallbackNode.children {
                if let mobileContentView = recurseAndRender(node: childNode, pageModel: pageModel) {
                    viewToRender = mobileContentView
                    break
                }
            }
            return viewToRender
        }
         
        let mobileContentView: MobileContentView? = getViewFromViewFactory(renderableNode: renderableNode, pageModel: pageModel)
        
        for childNode in node.children {
            
            let childMobileContentView: MobileContentView? = recurseAndRender(node: childNode, pageModel: pageModel)
            
            if let childMobileContentView = childMobileContentView, let mobileContentView = mobileContentView {
                mobileContentView.renderChild(childView: childMobileContentView)
            }
        }
        
        mobileContentView?.finishedRenderingChildren()
        
        return mobileContentView
    }
    
    private func getViewFromViewFactory(renderableNode: MobileContentRenderableNode, pageModel: MobileContentRendererPageModel) -> MobileContentView? {
        
        for viewFactory in pageViewFactories {
            
            if let view = viewFactory.viewForRenderableNode(renderableNode: renderableNode, pageModel: pageModel) {
            
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
