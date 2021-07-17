//
//  MobileContentXmlParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentXmlParser: MobileContentParserType {
    
    typealias PageListenerEventName = String
    typealias PageNumber = Int
    
    private let mobileContentNodeParser: MobileContentXmlNodeParser = MobileContentXmlNodeParser()
    private let pageListeners: [PageListenerEventName: PageNumber]
    
    let manifest: MobileContentManifestType
    let pageNodes: [PageNode]
    let errors: [Error]
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
        
        let manifest: MobileContentXmlManifest = MobileContentXmlManifest(translationManifestData: translationManifestData)
        
        let pageNodesResult = MobileContentXmlParser.getPageNodesFromManifest(
            manifest: manifest,
            mobileContentNodeParser: mobileContentNodeParser,
            translationsFileCache: translationsFileCache
        )
        
        switch pageNodesResult {
        
        case .success(let pageNodes):
            self.pageNodes = pageNodes
            self.pageListeners = MobileContentXmlParser.getPageListeners(pageNodes: pageNodes)
            self.errors = Array()
        
        case .failure(let error):
            self.pageNodes = Array()
            self.pageListeners = Dictionary()
            self.errors = [error]
        }
        
        self.manifest = manifest
    }
    
    required init(manifest: MobileContentManifestType, pageNodes: [PageNode]) {
        
        self.manifest = manifest
        self.pageNodes = pageNodes
        self.pageListeners = MobileContentXmlParser.getPageListeners(pageNodes: pageNodes)
        self.errors = Array()
    }
    
    var pageModels: [PageModelType] {
        return pageNodes
    }
    
    func getPageForListenerEvents(events: [String]) -> Int? {
        for event in events {
            if let page = pageListeners[event] {
                return page
            }
        }
        return nil
    }
    
    func getPageNode(page: Int) -> PageNode? {
        
        guard page >= 0 && page < pageNodes.count else {
            return nil
        }
        
        return pageNodes[page]
    }
    
    private static func getPageListeners(pageNodes: [PageNode]) -> [PageListenerEventName: PageNumber] {
        
        var pageListeners: [PageListenerEventName: PageNumber] = Dictionary()
        
        for pageIndex in 0 ..< pageNodes.count {
            let pageNode: PageNode = pageNodes[pageIndex]
            for listener in pageNode.listeners {
                pageListeners[listener] = pageIndex
            }
        }
        
        return pageListeners
    }
        
    // MARK: - Parsing Page Nodes
    
    private static func getPageNodesFromManifest(manifest: MobileContentXmlManifest, mobileContentNodeParser: MobileContentXmlNodeParser, translationsFileCache: TranslationsFileCache) -> Result<[PageNode], Error> {
        
        var allPageNodes: [PageNode] = Array()
        var errors: [Error] = Array()
    
        let manifestPages: [MobileContentManifestPageType] = manifest.pages
        
        for pageIndex in 0 ..< manifestPages.count {
            
            let result = MobileContentXmlParser.parsePageNode(
                manifest: manifest,
                mobileContentNodeParser: mobileContentNodeParser,
                translationsFileCache: translationsFileCache,
                page: pageIndex
            )
            
            switch result {
            
            case .success(let pageNode):
                allPageNodes.append(pageNode)
            
            case .failure(let error):
                errors.append(error)
            }
        }
        
        if let error = errors.first {
            return .failure(error)
        }
        else {
            return .success(allPageNodes)
        }
    }
    
    private static func parsePageNode(manifest: MobileContentManifestType, mobileContentNodeParser: MobileContentXmlNodeParser, translationsFileCache: TranslationsFileCache, page: Int) -> Result<PageNode, Error> {
        
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
