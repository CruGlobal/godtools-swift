//
//  ArticleManifestJSON.swift
//  godtools
//
//  Created by Igor Ostriz on 30/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation
import SwiftyJSON


struct ArticleData: Codable, Hashable {
    
    var title: String?
    var uri: String?
    var url: URL?
    
}




class ArticleManifestMetadata: NSObject {

    var json: JSON
    var url: URL

    
    private override init() {
        assert(false, "Cannot happen")
        fatalError()
    }
    
    init(json: JSON, url: URL) {
        self.json = json
        self.url = url
        super.init()
    }


    // returns dictionary with "tag" key and an array of corresponding articles
    func processMetadata(tags: Set<String?>) -> [String:Set<ArticleData>]? {
        
        var artData = [String:Set<ArticleData>]()
        
        func process(json: JSON, currentPath: String) {
            
            
            let content = json["jcr:content"]

            if !content.isEmpty {

                if !GTConstants.kArticleSupportedTemplates.contains(content["cq:template"].stringValue) {
                    return // not our template -> return
                }

                // this is our guy
                var data = ArticleData()
                data.title = content["jcr:title"].string
                data.uri = currentPath
                data.url = self.url.appendingPathComponent(currentPath + ".html")
                
                // add to results, only if cq:tags are contained in manifest tags
                let tagsAll = content["cq:tags"].arrayValue.map { $0.stringValue }
                for tag in tagsAll {
                    if !tags.contains(tag) {
                        continue
                    }
                    if artData[tag] == nil {
                        artData[tag] = Set()
                    }
                    artData[tag]?.insert(data)
                }
            }
            
            // search for non-namespaced children -> recurse into
            for (key, subJson):(String, JSON) in json {
                if key.contains(":") {
                    continue
                }
                process(json:subJson, currentPath: "\(currentPath)/\(key)")
            }
        }
        
        
        
        process(json: json, currentPath: "")
        
        
        
        
        return artData;
    }

}
