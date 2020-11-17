//
//  ToolLanguageTranslationModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolLanguageTranslationModel {
        
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    
    private var pageNodeCache: [Int: PageNode] = Dictionary()
    
    let language: LanguageModel
    let manifest: MobileContentXmlManifest
    
    required init(language: LanguageModel, translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser) {
        
        self.language = language
        self.manifest = MobileContentXmlManifest(translationManifest: translationManifestData)
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
    }
    
    func getToolPageNode(page: Int) -> PageNode? {
        
        let manifestPage: MobileContentXmlManifestPage = manifest.pages[page]
        let pageXmlCacheLocation: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: manifestPage.src)
        
        let pageXml: Data?
        let pageNode: PageNode?
        
        if let cachedPageNode = pageNodeCache[page] {
            pageNode = cachedPageNode
        }
        else {

            switch translationsFileCache.getData(location: pageXmlCacheLocation) {
                
            case .success(let pageXmlData):
                pageXml = pageXmlData
            case .failure(let error):
                pageXml = nil
            }
            
            // TODO: Would it be better to return page xml and have tool pages build themselves as nodes are built? ~Levi
            
            guard let pageXmlData = pageXml else {
                return nil
            }
            
            pageNode = mobileContentNodeParser.parse(xml: pageXmlData, delegate: nil) as? PageNode
            
            pageNodeCache[page] = pageNode
        }
        
        return pageNode
    }
}
