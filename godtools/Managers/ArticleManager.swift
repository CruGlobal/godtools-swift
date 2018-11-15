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

    
    var resources = DownloadedResources()
    
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: [XMLPage], categories: [XMLCategory], manifestProperties: ManifestProperties) {
        
        assert(resource.toolType == "article")
        
        var pages = [XMLPage]()
        var categories = [XMLCategory]()
        let manifestProperties = ManifestProperties()
        var xmlData: XMLIndexer?
        
        guard let translation = resource.getTranslationForLanguage(language) else {
            return (pages, categories, manifestProperties)
        }
        
        guard let manifestPath = translation.manifestFilename else {
            return (pages, categories, manifestProperties)
        }
            
        xmlData = loadXMLFile(manifestPath)
        
        guard let manifest = xmlData?["manifest"] else {
            return (pages, categories, manifestProperties)
        }
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        manifestProperties.load(manifestContent.properties)
        
        // load article pages
//        let totalPages = manifest["pages"].children.count
        for child in manifest["pages"].children {
            if child.element?.name == "article:aem-import" {
                // TODO: add downloading json/html data to "Download"
                let page = loadPage(child)
                pages.append(page)
            }
        }
        
        for child in manifest["resources"].children {
            let filename = child.element?.attribute(by: "filename")?.text
            let src = child.element?.attribute(by: "src")?.text
            let resource = documentsPath.appending("/Resources/").appending(src!)
            manifestProperties.resources[filename!] = resource
        }
        

        // load article categories
        for child in manifest["categories"].children {
            let category = loadCategory(child)
            debugPrint("\(category.label() ?? "err")")
            categories.append(category)
            
        }
        
        
        return (pages, categories, manifestProperties)
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLPage{

        // TODO: for now...
        return XMLPage(withXML: child)
        
//        let resource = child.element?.attribute(by: "src")?.text
//        let pageXML = loadXMLFile(resource!)
//        let page = XMLPage(withXML: pageXML!)
//        return page
    }
    
    func loadCategory(_ child: XMLIndexer) -> XMLCategory {
        return XMLCategory(withXML: child)
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

    
    
    
    
    
    func loadResourceList() {
//        var predicate: NSPredicate
        
//        resources = findEntities(DownloadedResource.self, matching: predicate)
    }

    
    
    
    
}


extension ArticleManager: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    

    
}
