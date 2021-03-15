//
//  ToolLanguageTranslationModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolLanguageTranslationModel {
        
    typealias PageNumber = Int
    
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let pagesNodeParser: ToolPagesNodeParser
        
    private var pageNodes: [Int: PageNode] = Dictionary()
    
    let language: LanguageModel
    let manifest: MobileContentXmlManifest
    let pagesListenersNotifier: ToolPagesListenersNotifier
    
    required init(language: LanguageModel, translationManifestData: TranslationManifestData, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentEvents: MobileContentEvents) {
        
        self.language = language
        self.manifest = MobileContentXmlManifest(translationManifest: translationManifestData)
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.pagesNodeParser = ToolPagesNodeParser()
        self.pagesListenersNotifier = ToolPagesListenersNotifier(mobileContentEvents: mobileContentEvents)
                
        pagesNodeParser.asyncParseAllPageNodes(manifest: manifest, translationsFileCache: translationsFileCache, mobileContentNodeParser: mobileContentNodeParser) { [weak self] (page: Int, pageNode: PageNode?, error: Error?) in
        
            if let pageNode = pageNode {
                self?.pageNodes[page] = pageNode
                self?.pagesListenersNotifier.addPageListeners(pageNode: pageNode, page: page)
            }
        } completion: { [weak self] (errors: [Error]) in
            
        }
    }
    
    func setToolPageListenersNotifierDelegate(delegate: ToolPagesListenersNotifierDelegate) {
        pagesListenersNotifier.setListenersNotifierDelegate(delegate: delegate)
    }
    
    func getPageNode(page: Int) -> PageNode? {
        
        if let pageNode = pageNodes[page] {
            return pageNode
        }
        
        let result: Result<PageNode, Error> = pagesNodeParser.parsePageNode(
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser,
            page: page
        )
        
        switch result {
        
        case .success(let pageNode):
            return pageNode
        
        case .failure(let error):
            return nil
        }
    }
}
