//
//  ArticleManager+Promises.swift
//  godtools
//
//  Created by Igor Ostriz on 12/12/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import PromiseKit
import SwiftyJSON


extension ArticleManager {
    

    // Promise for downloading everything
    func dnloadWholeManifestData(manifestFilename: String?) -> Promise<Void> {
        
        let xmlData = loadXMLFile(manifestFilename!)
        let manifest = xmlData?["manifest"]

        let pgs = XMLArticlePages(withXML: manifest!["pages"])
        
        let metadataPromises = getMetadataPromises(aemSources: pgs.aemSources())
        
        return when(fulfilled: metadataPromises).then { _ -> Promise<Void> in
            let webarchivePromises = self.getWebArchivePromises()

            return when(fulfilled: webarchivePromises).then { _ -> Void in


            }.catch(execute: { (err) in

            })
        }
    }
    
    
    func getMetadataPromises(aemSources: [String?]) -> [Promise<Void>] {

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
                    
                    // process downloaded json
                    let json = JSON(jsonData)
                    
                    // process each metadata json to get ArticleData from it
                    let metadata = ArticleManifestMetadata(json: json, url:url)
                    if let artData = metadata.processMetadata(tags:self.aemTags) {
                        // merge this data with
                        for (key, value) in artData {
                            if self.articlesDataForTag[key] == nil {
                                self.articlesDataForTag[key] = Set()
                            }
                            self.articlesDataForTag[key]?.formUnion(value)
                            
                        }
                    }
                    return Promise<Void>()
                }
            
            promises.append(promise)

        }
        return promises
    }
    
    func getWebArchivePromises() -> [Promise<Void>] {
        
        let baseFolder = URL(fileURLWithPath: self.documentsPath.appending("/WebCache/").appending(self.articleManifestID!))
        
        // composed articles promises
        var promises = [Promise<Void>]()
        
        
        // in key is aem-tag, value is a list of all ArticleData for the given tag
        for (key, value) in self.articlesDataForTag {
            debugPrint("Key: \(key)")
            
            var foldCnt: Int = 0
            
            // replace slashes '/' in keys with '#'
            // faith-topics:jesus-christ/life-of-jesus -> faith-topics:jesus-christ#life-of-jesus
            let folder = baseFolder.appendingPathComponent(key.replacingOccurrences(of: "/", with: "#"))
            
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
        
        guard let url = url?.appendingPathComponent(".999.json") else { return Promise(error: ArticleError.invalidURL) }
        
        let request = URLRequest(url: url)
        let dataTask  = URLSession.shared.dataTask(with: request) as URLDataPromise
        
        return dataTask.asDataAndResponse().then { d, response -> Promise<Data> in
            
            debugPrint("Downloaded JSON: \(url.absoluteString)")
            return Promise(value: d)
        }
    }

    
    

    // Downloading (as complete archive) web page
    func getWebArchive(url: URL) -> Promise<Data> {
        
        return Promise<Data> { fulfill, reject in
            
            WebArchiver.archive(url: url, completion: { result -> Void in
                switch result {
                case .success(let plistData):
                    debugPrint("Downloaded webarchive: \(url.absoluteString)")
                    fulfill(plistData)
                    
                case .failure(let error):
                    debugPrint("Failed downloading webarchive: \(url.absoluteString)")
                    reject(error)
                }
                
            })
        }
    }
    
    // Save .webarchive & ArticleData
    func saveWebArchive(folderUrl: URL, webArchData: Data, additionalProperties: ArticleData) -> Promise<Void> {
        
        return Promise<Void> { fulfill, reject in
            try? FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
            
            do {
                
                let data = try JSONEncoder().encode(additionalProperties)
                // write properties and webcache
                try data.write(to: folderUrl.appendingPathComponent("properties"))
                try webArchData.write(to: folderUrl.appendingPathComponent("page.webarchive"))

                debugPrint("Saved archives to: \(folderUrl.absoluteString)")
                fulfill()

            } catch {
                debugPrint("Error: \(error.localizedDescription)")
                reject(error)
            }
            
        }
        
    }

}
