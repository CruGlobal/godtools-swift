//
//  ArticleManager.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Crashlytics
import Foundation
import SWXMLHash


class ArticleManager: GTDataManager {

    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [XMLPage], manifestProperties: ManifestProperties) {
        
        assert(resource.toolType == "article")
        
        var pages = [XMLPage]()
        let manifestProperties = ManifestProperties()
        var xmlData: XMLIndexer?
        
        guard let translation = resource.getTranslationForLanguage(language) else {
            return (pages, manifestProperties)
        }
        
        guard let manifestPath = translation.manifestFilename else {
            return (pages, manifestProperties)
        }
            
        xmlData = loadXMLFile(manifestPath)
        
        guard let manifest = xmlData?["manifest"] else {
            return (pages, manifestProperties)
        }
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        manifestProperties.load(manifestContent.properties)
        
        // load article pages
        let totalPages = manifest["pages"].children.count
        var currentPage = 1
        for child in manifest["pages"].children {
            if child.element?.name == "page" {
                let page = loadPage(child)
                page.pagination = TractPagination(totalPages: totalPages, pageNumber: currentPage)
                pages.append(page)
                currentPage += 1
            }
        }
        
        for child in manifest["resources"].children {
            let filename = child.element?.attribute(by: "filename")?.text
            let src = child.element?.attribute(by: "src")?.text
            let resource = documentsPath.appending("/Resources/").appending(src!)
            manifestProperties.resources[filename!] = resource
        }
        
        
        
        // load article categories
        let catcnt = manifest["categories"].children.count
        
        if catcnt > 0 {
            
            for child in manifest["categories"].children {
                
            }
            
            
        }
        
        
        return (pages, manifestProperties)
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLPage{
        let resource = child.element?.attribute(by: "src")?.text
        let pageXML = loadXMLFile(resource!)
        let page = XMLPage(withXML: pageXML!)
        return page
    }
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {
        let file = documentsPath.appending("/Resources/").appending(resourcePath)
        
        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            xml = SWXMLHash.parse(content)
        }
        catch {
            Crashlytics().recordError(error,
                                      withAdditionalUserInfo: ["customMessage": "Error while reading the XML"])
        }
        
        return xml
    }

    
    
}
