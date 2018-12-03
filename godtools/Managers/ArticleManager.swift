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
//        case invalidResponse
        
        var errorDescription: String? {
            switch self {
            case .requestMetadataFailed(let string, _): return "Metadata downloading failed: " + string
            case .invalidMetadataJSON: return "Invalid JSON metadata."
            case .invalidURL: return "Invalid URL"
//            case .invalidResponse: "iInvalid response"
            }
        }
    }

    
    var categories: [XMLArticleCategory]?
    var pages: XMLArticlePages?
    var manifestProperties: ManifestProperties?
    
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
            debugPrint("\(category.label() ?? "err")")
            categories!.append(category)
            
        }
        
        downloadManifest(uuid: "TODO")
        
        return (pages!, categories!, manifestProperties!)
    }
    
    func downloadManifest(uuid: String) {
        assert(manifestProperties != nil)
        
//        guard let mProp = manifestProperties else {
//            return
//        }
        guard let pages = pages else {
            return
        }
        
        for src in pages.aemSources() {
            
            guard let src = src, let url = URL(string: src) else {
                continue
            }
            
            firstly {
                self.download(baseURL: url, pathComponent: ".999.json")
            }.then { jsonData in
//                let json = JSON(jsonData)
                self.saveToDisk(jsonData)
            }.then { _ in
                self.download(baseURL: url, pathComponent: "master.html")
            }.then { data in
                self.saveToDisk(data)
            }.catch { (error) in
                debugPrint("Error downloading url: \(src)")
            }
            
            
        }
    }

    func download(baseURL: URL?, pathComponent: String) -> Promise<Data> {
        
        guard let url = baseURL?.appendingPathComponent(pathComponent) else { return Promise(error: ArticleError.invalidURL) }
        let request = URLRequest(url: url)
        let dataTask  = URLSession.shared.dataTask(with: request) as URLDataPromise
        
        return dataTask.asDataAndResponse().then { (d, response) -> Promise<Data> in
            
//            let json = JSON(d)
            return Promise(value: d)
        }
    }
    

   
    func saveToDisk(_ data:Data) -> Promise<Void> {
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
            Crashlytics().recordError(error,
                                      withAdditionalUserInfo: ["customMessage": "Error while reading the XML"])
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
