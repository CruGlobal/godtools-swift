//
//  ArticleManager.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Crashlytics
import Foundation
import PromiseKit
import SwiftyJSON
import SWXMLHash


class ArticleManager: GTDataManager {

    
    
    enum ArticleError: LocalizedError {
        case requestMetadataFailed(resourceURLString: String, error: Error)
        case invalidMetadataJSON
        case invalidURL
        case downloadingWebPage(pageURLString: String, error: Error)
        
        var errorDescription: String? {
            switch self {
            case .requestMetadataFailed(let string, _): return "Metadata downloading failed: " + string
            case .invalidMetadataJSON: return "Invalid JSON metadata."
            case .invalidURL: return "Invalid URL"
            case .downloadingWebPage(let urls, let err): return "Downloading page" + urls + ": error:" + err.localizedDescription
            }
        }
    }

    
    
    var aemTags = Set<String>()    // set of all aem-tags in this manifest
    var articlesDataForTag = Dictionary<String, Set<ArticleData>>()

    var categories: [XMLArticleCategory] = [XMLArticleCategory]()
    var pages: XMLArticlePages?
    var manifestProperties: ManifestProperties?
    var articleManifestID: String?
    var articlesPath: String?
    var articleManifestFilename: String?
    
    func loadResource(resource: DownloadedResource, language: Language) -> (pages: XMLArticlePages?, categories: [XMLArticleCategory]?, manifestProperties: ManifestProperties?) {
        
        assert(resource.toolType == "article")
        
        categories = [XMLArticleCategory]()
        manifestProperties = ManifestProperties()
        var xmlData: XMLIndexer?
        
        guard let translation = resource.getTranslationForLanguage(language),
              let manifestPath = translation.manifestFilename
        else {
            return (pages, categories, manifestProperties)
        }
        
        var components = manifestPath.components(separatedBy: ".")
        components.removeLast()
        articleManifestID = components.joined(separator: ".")
        articleManifestFilename = translation.manifestFilename
        articlesPath = documentsPath.appending("/WebCache/").appending(articleManifestID!).appending("/")
        
        xmlData = loadXMLFile(manifestPath)
        
        guard let manifest = xmlData?["manifest"] else {
            return (pages, categories, manifestProperties)
        }
        
        let xmlManager = XMLManager()
        let manifestContent = xmlManager.getContentElements(manifest)
        manifestProperties!.load(manifestContent.properties)
        
        
        // load article pages
        
        
        pages = XMLArticlePages(withXML: manifest["pages"])
        if pages == nil {
            return (pages, categories, manifestProperties)
        }
        
        for child in manifest["resources"].children {
            let filename = child.element?.attribute(by: "filename")?.text
            let src = child.element?.attribute(by: "src")?.text
            let resource = documentsPath.appending("/Resources/").appending(src!)
            manifestProperties!.resources[filename!] = resource
        }
        
        // load article categories
        for child in manifest["categories"].children {
            let category = XMLArticleCategory(withXML: child)
            aemTags.formUnion(category.aemTagIDs())
            debugPrint("\(category.label() ?? "err")")
            categories.append(category)
        }
        
        processManifest(uuid: articleManifestID)
        
        return (pages!, categories, manifestProperties!)
    }
    


    func processManifest(uuid: String?) {
        assert(manifestProperties != nil)
        
        dnloadWholeManifestData(manifestFilename: articleManifestFilename).then {
            debugPrint("Done. Should reload tableView here.")
        }
    }

    
    
    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {

        let file = documentsPath.appending("/Resources/").appending(resourcePath)

        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            xml = SWXMLHash.parse(content)
        }
        catch {
            Crashlytics().recordError(error,  withAdditionalUserInfo: ["customMessage": "Error while reading the XML"])
        }

        return xml
    }

    
    func getImage(forCategory: XMLArticleCategory) -> UIImage? {
        
        guard let imagePath = manifestProperties?.getResourceForFile(filename: forCategory.banner()!) else {
            return nil
        }
        guard let data = NSData(contentsOfFile: imagePath) else {
            return nil
        }
        guard let image = UIImage(data: data as Data) else {
            return nil
        }

        return image
    }
    
    func getTitle(forCategory: XMLArticleCategory) -> String? {
        return forCategory.label()
    }
    
    func buildURL(aemSource: String) -> URL? {
        return Config.shared().baseUrl?
            .appendingPathComponent(aemSource)
    }
    
}



