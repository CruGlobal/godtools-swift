//
//  TractManager.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TractManager {
    
    private let translationsFileCache: TranslationsFileCache
    private let resourcesSHA256FileCache: ResourcesSHA256FileCache
    
    required init(translationsFileCache: TranslationsFileCache, resourcesSHA256FileCache: ResourcesSHA256FileCache) {
        
        self.translationsFileCache = translationsFileCache
        self.resourcesSHA256FileCache = resourcesSHA256FileCache
    }
    
    func loadResource(translationManifest: TranslationManifestData) -> TractXmlResource {
        
        var pages = [XMLPage]()
        let manifestProperties = ManifestProperties(sha256FileCache: resourcesSHA256FileCache)
                
        let xmlData: XMLIndexer = SWXMLHash.parse(translationManifest.manifestXmlData)
        let manifest: XMLIndexer = xmlData["manifest"]
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        manifestProperties.load(manifestContent.properties)
        
        let totalPages = manifest["pages"].children.count
        var currentPage = 1
        for child in manifest["pages"].children {
            if child.element?.name == "page" {
                if let page = loadPage(child) {
                    page.pagination = TractPagination(totalPages: totalPages, pageNumber: currentPage)
                    pages.append(page)
                    currentPage += 1
                }
            }
        }
        
        for child in manifest["resources"].children {
            
            if let filename = child.element?.attribute(by: "filename")?.text, let src = child.element?.attribute(by: "src")?.text {
                
                let location: SHA256FileLocation = SHA256FileLocation(sha256WithPathExtension: src)
                manifestProperties.resources[filename] = location
            }
        }
        
        return TractXmlResource(pages: pages, manifestProperties: manifestProperties)
    }
    
    private func loadPage(_ child: XMLIndexer) -> XMLPage? {
        
        let pageXmlFile: String? = child.element?.attribute(by: "src")?.text
        
        var pageXmlData: Data?
        
        if let pageXmlFile = pageXmlFile {
            
            switch translationsFileCache.getData(location: SHA256FileLocation(sha256WithPathExtension: pageXmlFile)) {
            case .success(let xmlData):
                pageXmlData = xmlData
            case .failure(let error):
                break
            }
        }
        
        if let pageXmlData = pageXmlData {
            
            let pageXml: XMLIndexer = SWXMLHash.parse(pageXmlData)
            
            return XMLPage(withXML: pageXml)
        }
        
        return nil
    }
}
