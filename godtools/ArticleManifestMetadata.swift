//
//  ArticleManifestJSON.swift
//  godtools
//
//  Created by Igor Ostriz on 30/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation
import SwiftyJSON




struct ArticleData: Codable, Hashable, Comparable {
    
    static func < (lhs: ArticleData, rhs: ArticleData) -> Bool {
        return lhs.title! < rhs.title!
    }
    static func == (lhs: ArticleData, rhs: ArticleData) -> Bool {
        let b = lhs.url?.path == rhs.url?.path
        print("----\nEqual:\(b)   \nlhs:\(lhs.title ?? "")\nrhs:\(rhs.title ?? "")")
        return lhs.url?.path == rhs.url?.path
    }
    

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.url)
    }
    
    var title: String?
    var url: URL?
    var local: URL?
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

    // returns dictionary with aemtag  key and the set of corresponding articles
    func processMetadata(tags: Set<String?>) -> [String:Set<ArticleData>] {
        
        var result = [String:Set<ArticleData>]()
        
        func process(json: JSON, currentPath: String) {
            
            let content = json["jcr:content"]

            if !content.isEmpty && GTConstants.kArticleSupportedTemplates.contains(content["cq:template"].stringValue) {


                // this is our ArticleData
                var data = ArticleData()
                data.title = content["jcr:title"].string
                data.url = self.url.appendingPathComponent(currentPath + ".html")
                
                // add to results, only if cq:tags are contained in manifest tags
                let tagsAll = content["cq:tags"].arrayValue.map { $0.stringValue }
                for tag in tagsAll {
                    if !tags.contains(tag) {
                        continue
                    }
                    if result[tag] == nil {
                        result[tag] = Set()
                    }

                    result[tag]!.insert(data)
#if DEBUG
                    print("---------------- currentPath: \(tag):  \(currentPath)")
#endif

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


        return result;
    }

}
