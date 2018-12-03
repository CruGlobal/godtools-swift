//
//  ArticleManager.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Alamofire
import Crashlytics
import Foundation
import PromiseKit
import SwiftyJSON
import SWXMLHash


class ArticleManager: GTDataManager {

    
    enum ArticleError: LocalizedError {
        case requestMetadataFailed(resourceURLString: String, error: Error)
        case corruptMetadataJSON
        
        
        var errorDescription: String? {
            switch self {
            case .requestMetadataFailed(let string, _): return "Metadata downloading failed: " + string
            case .corruptMetadataJSON: return "Invalid JSON metadata."
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
        
        
        
//        for child in manifest["pages"].children {
//            if child.element?.name == "article:aem-import" {
//                // TODO: add downloading json/html data to "Download"
//                let page = loadPage(child)
//                pages!.append(page)
//            }
//        }
        
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
        
        downloadManifest()
        
        return (pages!, categories!, manifestProperties!)
    }
    
    func downloadManifest() {
        assert(manifestProperties != nil)
        
        guard let mProp = manifestProperties else {
            return
        }
        guard let pages = pages else {
            return
        }
        
        for src in pages.aemSources() {
            
            guard let src = src, let url = URL(string: src)?.appendingPathComponent(".999.json") else {
                continue
            }
            
            firstly {
                URLSession.shared.dataTask(.promise, with:url)
            }.compactMap { data, _ in
                    
                return data
            }
            
            
//            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//                guard let dataResponse = data, error == nil else {
//                    print(error?.localizedDescription ?? "Response Error")
//                    return
//                }
//                do {
////                    let manifestJSON = JSONResourceFactory.initializeArrayFrom(data: data, type: JSONResource)
//                    let manifestJSON = try JSONSerialization.jsonObject(with: dataResponse, options: [])
//                    print(manifestJSON) //Response result
//
////                    self.saveToDisk(manifestJSON)
//
//                } catch let parsingError {
//                    print("Error", parsingError)
//                }
//            }
//            task.resume()
            
            
            Alamofire.request(url).responseData().then { data in

                guard let json = try? JSON(data: data) else { throw ArticleError.corruptMetadataJSON }

                DispatchQueue.global(qos: .userInitiated).async {
                    
                    
                    DispatchQueue.main.async {

                        self.saveToDisk(json)

                    }
                }

//                return Promise(value:self.loadFromDisk())
            }.catch { (error) in
                
            }
        }
        
        
    }
    
    private func saveToDisk(_ resource:JSON) {

//        func saveToDisk(_ jsonManifest: JSONResource) {
        
        // save json manifest to disk
        debugPrint(resource)
    }
    
    func downloadJSON(page: XMLArticlePages)  {
        
        let base = page.aemSources()
//        Alamofire.request().the

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
    
    private func buildURL(aemSource: String) -> URL? {
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
