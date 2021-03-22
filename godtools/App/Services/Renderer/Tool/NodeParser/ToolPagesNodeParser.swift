//
//  ToolPagesNodeParser.swift
//  godtools
//
//  Created by Levi Eggert on 11/17/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class ToolPagesNodeParser {
                
    required init() {
        
    }
    
    func asyncParseAllPageNodes(manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, didParsePageNode: @escaping ((_ page: Int, _ pageNode: PageNode?, _ error: Error?) -> Void), completion: @escaping ((_ errors: [Error]) -> Void)) {
        
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
                    mobileContentNodeParser: mobileContentNodeParser,
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
    
    func parsePageNode(manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, page: Int) -> Result<PageNode, Error> {
        
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
