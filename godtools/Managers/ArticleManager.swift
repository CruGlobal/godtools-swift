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

    var categories: [XMLArticleCategory]?
    var pages: XMLArticlePages?
    var manifestProperties: ManifestProperties?
    var articleManifestID: String?
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
        
        // load article resources (for images)
        for child in manifest["resources"].children {
            let filename = child.element?.attribute(by: "filename")?.text
            let src = child.element?.attribute(by: "src")?.text
            let resource = documentsPath.appending("/Resources/").appending(src!)
            manifestProperties!.resources[filename!] = resource
        }
        
        // load article categories
        for child in manifest["categories"].children {
            let category = loadCategory(child)
            aemTags.formUnion(category.aemTagIDs())
            debugPrint("\(category.label() ?? "err")")
            categories!.append(category)
            
        }
        
        processManifest(uuid: articleManifestID)
        
        return (pages!, categories!, manifestProperties!)
    }
    


    func processManifest(uuid: String?) {
        assert(manifestProperties != nil)
        
        dnloadWholeManifestData(manifestFilename: articleManifestFilename).then {
            debugPrint("Done. Should reload tableView here.")
        }

//        guard let pages = pages else {
//            return
//        }
//
//        // get all metadata from aem-sources
//
//        var articleManifestMetadatas: [JSON] = [JSON]()
//
//        // array of promises
//        var promises = [Promise<Void>]()
//
//        for src in pages.aemSources() {
//
//            guard let src = src,
//                let url = URL(string: src) else {
//                continue
//            }
//
//            let promise = firstly {
//
//                self.downloadMetadata(url: url)
//
//            }.then { jsonData -> JSON in
//
//                // collect all (downloaded) metadata into one array
//                let json = JSON(jsonData)
//                articleManifestMetadatas.append(json)
//
//                return json
//            }.then { json -> Void in
//
//                // process each metadata
//                let metadata = ArticleManifestMetadata(json: json, url:url)
//                if let artData = metadata.processMetadata(tags:self.aemTags) {
//                    // merge this data with
//                    for (key, value) in artData {
//                        if self.articlesDataForTag[key] == nil {
//                            self.articlesDataForTag[key] = Set()
//                        }
//                        self.articlesDataForTag[key]?.formUnion(value)
//
//                    }
//                }
//            }
//
//            promises.append(promise)
//        }
//
//
//        when(fulfilled: promises).then { _ -> Promise<Void> in
//
//            // create cache folder(s)
//            let baseFolder = URL(fileURLWithPath: self.documentsPath.appending("/WebCache/").appending(uuid!))
//
//            try FileManager.default.createDirectory(at: baseFolder, withIntermediateDirectories: true, attributes: nil)
//
//            for (key, value) in self.articlesDataForTag {
//                debugPrint("Key: \(key)")
//
//                var foldCnt: Int = 0
//                let folder = baseFolder.appendingPathComponent(key)
//                for artData in value {
//
//                    WebArchiver.archive(url: artData.url!, completion: { [foldCnt] result -> Void in
//                        do {
//                            switch result {
//                            case .success(let plistData):
//                                let f = folder.appendingPathComponent(String(format: "%02d", foldCnt))
//                                try FileManager.default.createDirectory(at: f, withIntermediateDirectories: true, attributes: nil)
//
//                                let data = try JSONEncoder().encode(artData)
//                                // write properties and webcache
//                                debugPrint(f.absoluteString)
//                                try data.write(to: f.appendingPathComponent("properties"))
//                                try plistData.write(to: f.appendingPathComponent("page.webarchive"))
//
//                            case .failure(let error):
//                                throw ArticleError.downloadingWebPage(pageURLString: (artData.url?.absoluteString)!, error: error)
//                            }
//                        }
//                        catch {
//                            // TODO: handle with crashlytics...
//                        }
//
//                    })
//
//                    foldCnt += 1
//                }
//            }
//
//
//            return Promise<Void>()
//        }.catch { (err) in
//            debugPrint("Error downloading url:")
//        }
        
    }

    
    
   
    func saveToDisk(_ fName: String, _ data:Data) -> Promise<Void> {
        
        guard let fld = articleManifestID else {
            return Promise(error: ArticleError.invalidURL)
        }
        
        let art = documentsPath.appending("/Articles/").appending(fld).appending(fName)

        
        
        return Promise<Void>()
    }

    
    
    func loadPage(_ child: XMLIndexer) -> XMLArticlePages{

        
        // TODO: for now...
        return XMLArticlePages(withXML: child)

//        let resource = child.element?.attribute(by: "src")?.text
//        let pageXML = loadXMLFile(resource!)
//        let page = XMLPage(withXML: pageXML!)
//        return page
    }

    func loadCategory(_ child: XMLIndexer) -> XMLArticleCategory {
        
        // load aem-tagshi
        
        return XMLArticleCategory(withXML: child)
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















extension ArticleManager: UITableViewDataSource, UITableViewDelegate {
    
    static let cellIdentifier = "articleCellID"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleManager.cellIdentifier) as! ArticleTableViewCell
        
        let category = categories![indexPath.row]
        let image = getImage(forCategory: category)
        cell.imgView.image = image
        cell.titleLabel.text = getTitle(forCategory: category)
        
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories!.count
    }

    

    
}
