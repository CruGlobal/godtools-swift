//
//  TractManager.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash
import Crashlytics

class TractManager: GTDataManager {
    
    let testMode = false

}

extension TractManager {
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [XMLPage], manifestProperties: ManifestProperties) {
        var pages = [XMLPage]()
        let manifestProperties = ManifestProperties()
        var xmlData: XMLIndexer?
        
        if testMode {
            let manifestPath = "kgp-manifest"
            xmlData = loadXMLFile(manifestPath)
        
        } else {
            guard let translation = resource.getTranslationForLanguage(language) else {
                return (pages, manifestProperties)
            }
            
            
            guard let manifestPath = translation.manifestFilename else {
                return (pages, manifestProperties)
            }
            
            xmlData = loadXMLFile(manifestPath)
        }
        
        guard let manifest = xmlData?["manifest"] else {
            return (pages, manifestProperties)
        }
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        manifestProperties.load(manifestContent.properties)
        
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
        
        return (pages, manifestProperties)
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLPage{
        let resource = child.element?.attribute(by: "src")?.text
        let pageXML = loadXMLFile(resource!)
        let page = XMLPage(withXML: pageXML!)
        return page
    }
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {
        let file = testMode ? Bundle.main.path(forResource: resourcePath, ofType: "xml") : documentsPath.appending("/Resources/").appending(resourcePath)
        
        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file!, encoding: String.Encoding.utf8)
            print("\(content)")
            xml = SWXMLHash.parse(content)
        }
        catch {
            Crashlytics().recordError(error,
                                      withAdditionalUserInfo: ["customMessage": "Error while reading the XML"])
        }
        
        return xml
    }
    
}
