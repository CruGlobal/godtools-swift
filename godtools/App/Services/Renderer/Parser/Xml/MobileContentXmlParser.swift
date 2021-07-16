//
//  MobileContentXmlParser.swift
//  godtools
//
//  Created by Levi Eggert on 7/16/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentXmlParser {
    
    typealias PageListenerEventName = String
    typealias PageNumber = Int
    
    private let mobileContentNodeParser: MobileContentXmlNodeParser = MobileContentXmlNodeParser()
    private let translationsFileCache: TranslationsFileCache
    private let pageListeners: [PageListenerEventName: PageNumber]
    
    let manifest: MobileContentXmlManifest
    let pageNodes: [PageNode]
    let errors: [Error]
    
    required init(translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache) {
        
        self.translationsFileCache = translationsFileCache
        self.manifest = MobileContentXmlManifest(translationManifestData: translationManifestData)
        
        var pageNodes: [PageNode] = Array()
        var pageListeners: [PageListenerEventName: PageNumber] = Dictionary()
    
        let manifestPages: [MobileContentManifestPageType] = manifest.pages
        
        var errors: [Error] = Array()
        
        for pageIndex in 0 ..< manifestPages.count {
            
            let result = MobileContentXmlParser.parsePageNode(
                manifest: manifest,
                mobileContentNodeParser: mobileContentNodeParser,
                translationsFileCache: translationsFileCache,
                page: pageIndex
            )
            
            switch result {
            
            case .success(let pageNode):
                
                for listener in pageNode.listeners {
                    pageListeners[listener] = pageIndex
                }
                
                pageNodes.append(pageNode)
            
            case .failure(let error):
                errors.append(error)
            }
        }
        
        self.pageNodes = pageNodes
        self.pageListeners = pageListeners
        self.errors = errors
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
    
    // MARK: - Parsing Page Nodes
    
    private static func parsePageNode(manifest: MobileContentXmlManifest, mobileContentNodeParser: MobileContentXmlNodeParser, translationsFileCache: TranslationsFileCache, page: Int) -> Result<PageNode, Error> {
        
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
