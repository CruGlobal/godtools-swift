//
//  ArticleManager.swift
//  godtools
//
//  Created by Igor Ostriz on 13/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation
import PromiseKit
import SwiftyJSON
import SWXMLHash

class ArticleManager: GTDataManager {
    
    var aemTags = Set<String>()    // set of all aem-tags in this manifest
    var articlesDataForTag = Dictionary<String, Set<ArticleData>>()

    var articlesTempPath: String?

    func loadXMLFile(_ resourcePath: String) -> XMLIndexer? {

        let file = documentsPath.appending("/Resources/").appending(resourcePath)

        var xml: XMLIndexer?
        do {
            let content = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            xml = SWXMLHash.parse(content)
        }
        catch let error {
            
        }

        return xml
    }
}

// MARK: - Promises

extension ArticleManager {
    
    
    // Promise for downloading everything
    func dnloadWholeManifestData(manifestFilename: String?) -> Promise<Void> {
        
        let xmlData = loadXMLFile(manifestFilename!)
        let manifest = xmlData?["manifest"]

        let pgs = XMLArticlePages(withXML: manifest!["pages"])
        
        let metadataPromises = getMetadataPromises(aemSources: pgs.aemSources())
        
        return when(fulfilled: metadataPromises).then { _ -> Promise<Void> in
                        
            let webarchivePromises = self.getWebArchivePromises()
            return when(fulfilled: webarchivePromises).then { rv -> Promise<Void> in
                
                .value(())
                
                }
                .ensure { }

        }
    }
    
    
    func getMetadataPromises(aemSources: [String?]) -> [Promise<Void>] {

        if !FileManager.default.fileExists(atPath: articlesTempPath!) {
            try! FileManager.default.createDirectory(atPath: articlesTempPath!, withIntermediateDirectories: true, attributes: nil)
        }
        
        // composed download promises
        var promises = [Promise<Void>]()
        
        for aemImport in aemSources {
            
            guard let src = aemImport, let url = URL(string: src) else {
                continue
            }
            
            let promise =
                
                firstly {
                    
                    downloadMetadata(url: url)
                    
                }.then { jsonData -> Promise<Void> in
                    
                    // save json file with unique name
                    let name = src.md5 + ".json"
                    let jsonURL = URL(fileURLWithPath: self.articlesTempPath! + name)
                    
                    do {
                        try jsonData.write(to: jsonURL)
                    } catch {
                        print("Error while writing JSON file: \(error.localizedDescription)")
                    }

                    // process each metadata json to get ArticleData from it
                    let json = JSON(jsonData)
                    
                    let metadata = ArticleManifestMetadata(json: json, url:url)
                    let artData = metadata.processMetadata(tags:self.aemTags)
                    
                    for (key, value) in artData {
                        if self.articlesDataForTag[key] == nil {
                            self.articlesDataForTag[key] = Set()
                        }
                        self.articlesDataForTag[key]!.formUnion(value)
                    }
                    
                    return Promise<Void>()
                }
            
            promises.append(promise)

        }
        return promises
    }
    
    
    
    func getWebArchivePromises() -> [Promise<Void>] {
        
        let baseFolder = URL(fileURLWithPath: self.articlesTempPath!)
        
        // composed articles promises
        var promises = [Promise<Void>]()
        
        
        // in key is aem-tag, value is a list of all ArticleData for the given tag
        for (key, value) in self.articlesDataForTag {
            
            var foldCnt: Int = 0
            
            // replace slashes '/' in keys with '--'
            // faith-topics:jesus-christ/life-of-jesus -> faith-topics:jesus-christ#life-of-jesus
            let folder = baseFolder.appendingPathComponent(key.replacingOccurrences(of: "/", with: "---"))
            
            for articleData in value {
                
                let f = folder.appendingPathComponent(String(format: "%02d", foldCnt))
                let p = self.getWebArchive(url: articleData.url!).then { plistData in
                    self.saveWebArchive(folderUrl: f, webArchData: plistData, additionalProperties: articleData)
                }
                
                foldCnt += 1
                promises.append(p)
            }
            
        }

        return promises
    }
    
    
    // Download metadata from manifest aem-import src
    func downloadMetadata(url: URL?) -> Promise<Data> {
        
        guard let url = url else { return Promise(error: ArticleError.invalidURL) }

        // cache the same result for one hour
        let finalURL = URL(string: url.cleanedPath + ".999.json?_=\(Int64( (NSDate().timeIntervalSince1970 / 3600.0).rounded() ))")
        let request = URLRequest(url: finalURL!)
        return URLSession.shared.dataTask(.promise, with: request).then { (arg) -> Promise<Data> in
            return .value(arg.data)
        }
    }


    // Downloading (as complete archive) web page
    func getWebArchive(url: URL) -> Promise<Data> {
        
        return Promise<Data> { seal in
            
            WebArchiver.archive(url: url, completion: { result -> Void in
                switch result {
                case .success(let plistData):
                    debugPrint("Downloaded webarchive: \(url.absoluteString)")
                    seal.fulfill(plistData)
                    
                case .failure(let error):
                    debugPrint("Failed downloading webarchive: \(url.absoluteString)")
                    seal.reject(error)
                }
            })
        }
    }
    
    
    // Save .webarchive & ArticleData
    func saveWebArchive(folderUrl: URL, webArchData: Data, additionalProperties: ArticleData) -> Promise<Void> {
        
        return Promise<Void> { seal in
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)

            do {
                let data = try JSONEncoder().encode(additionalProperties)
                try data.write(to: folderUrl.appendingPathComponent("properties"))
                try webArchData.write(to: folderUrl.appendingPathComponent("page.webarchive"))

                seal.fulfill(())

            } catch {
                debugPrint("Error: \(error.localizedDescription)")
                seal.reject(error)
            }

        }
    }
}


extension URL {
    
    // absoulute path is cleaned from parameters, fragments and eventual "<smtng>.html"
    var cleanedPath: String {
        
        var pth = self.absoluteString
        // remove parameters, '?' included
        if let index = (pth.range(of: "?")?.lowerBound) {
            pth = String(pth.prefix(upTo: index))
        }
        // remove all after fragment, '#' included
        if let index = (pth.range(of: "#")?.lowerBound) {
            pth = String(pth.prefix(upTo: index))
        }

        // remove last component if it contains .html
        var ar = pth.components(separatedBy: "/")
        if ar.last?.contains(".html") == true {
            ar.removeLast()
        }

        pth = ar.joined(separator: "/")
        return pth
    }
}
