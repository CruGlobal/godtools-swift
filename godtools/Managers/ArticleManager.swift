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
    var articlesTempPath: String?
    var articleManifestFilename: String?
    
    
    var downloadStatus = false {
        didSet {
            if let closure = downloadStatusChanged {
                closure(downloadStatus)
            }
        }
    }
    var downloadStatusChanged: ((Bool) -> Void)?
    
    
    func loadResource(resource: DownloadedResource, language: Language, forceDownload: Bool = false) -> (pages: XMLArticlePages?, categories: [XMLArticleCategory]?, manifestProperties: ManifestProperties?) {
        
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
        let articlesExist = FileManager.default.fileExists(atPath: articlesPath!)
        
        articlesTempPath = NSTemporaryDirectory().appending("WebCache/").appending(articleManifestID!).appending("/")
        
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
            let category = XMLArticleCategory(withXML: child, articleID: articleManifestID!)
            aemTags.formUnion(category.aemTagIDs())
            debugPrint("\(category.label() ?? "err")")
            categories.append(category)
        }
        
        processManifest(uuid: articleManifestID, shouldDownload: forceDownload || !articlesExist)
        
        return (pages!, categories, manifestProperties!)
    }
    


    func processManifest(uuid: String?, shouldDownload: Bool) {
        assert(manifestProperties != nil)
        
        let from = articlesTempPath!
        let to = articlesPath!
        
        if shouldDownload {

            downloadStatus = true
            
            dnloadWholeManifestData(manifestFilename: articleManifestFilename).then { [from, to, articleManifestID] _ -> Promise<Void> in
                
                do {
                    
                    if !FileManager.default.fileExists(atPath: to) {
                        // create the destination path (mainly because of .../WebArchive/... directory for the initial run (when it does not exist). It will create .../WebArchive/ArticleID,
                        //  but the last one (ArticleID) will be deleted in the following step
                        try! FileManager.default.createDirectory(atPath: to, withIntermediateDirectories: true, attributes: nil)
                    }
                    
                    try? FileManager.default.removeItem(atPath: to)
                    // copy all from tmp folder to the real one
                    try FileManager.default.copyItem(atPath: from, toPath: to)
                    // finaly remove tmp folder
                    try FileManager.default.removeItem(atPath: from)
                    
                }
                catch {
                    debugPrint("Error copying \(error.localizedDescription)")
                }
                
#if DEBUG
                
                debugPrint("\n\nFrom dir: \(from)")
                dirSlashS(atPath: from)
                debugPrint("\n\nTo dir: \(to)")
                dirSlashS(atPath: to)

                debugPrint("Done. Should reload tableView here.")
#endif
                NotificationCenter.default.post(name: .articleProcessingCompleted, object: nil, userInfo: ["articleID": articleManifestID!])
                
                return Promise<Void>()
            
            }
            .always {
                
                self.downloadStatus = false
            }
        }
        else {
            processManifestFromLocalData(manifestFilename: articleManifestFilename).then { [articleManifestID] _ -> Promise<Void> in
                NotificationCenter.default.post(name: .articleProcessingCompleted, object: nil, userInfo: ["articleID": articleManifestID!])
                return Promise<Void>()
            }
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


// output content of the directory and subfolders.
// similar to dir /s, from the early days
// does nothing in release

func dirSlashS(atPath path: String) {
#if DEBUG
    if let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: path).standardizedFileURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
        for case let fileURL as URL in enumerator {
            let p = fileURL.standardizedFileURL.absoluteString
            debugPrint("\(p.deletePrefix(URL(fileURLWithPath: path).standardizedFileURL.absoluteString))")
        }
    }
#endif
}


// dir <path>, "json"
// returns non-optional array of URLs

func dirWithFilter(atPath path: String, filter: String?) -> [URL]
{
    guard let directoryURL = URL(string: path) else {
        return []
    }
    
    var ar = [URL]()
    do {
        let contents = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        ar.append(contentsOf: contents.filter { (url) -> Bool in
            let last = FileManager.default.displayName(atPath: url.path)
            return last.contains(filter!)
        })

    } catch {
        debugPrint("Cannot list directory at: \(directoryURL.lastPathComponent) with filter: \(filter ?? "nil")")
    }
    
    return ar
}


