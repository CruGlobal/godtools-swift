//
//  XMLCategory.swift
//  godtools
//
//  Created by Igor Ostriz on 15/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import UIKit
import SWXMLHash


class XMLArticleCategory: NSObject {

    var content: XMLIndexer?
    var articleID: String

    var title: String? {
        return self.label()
    }
    
    

    @available(*, unavailable, message: "Use init with arguments")
    override init() {
        fatalError()    // cumbersome
    }
    
    init(withXML content: XMLIndexer, articleID: String) {
        self.content = content
        self.articleID = articleID
        super.init()
    }
    
    
    
    func label() -> String? {
        return content?["label"]["content:text"].element?.text
    }

    func id() -> String? {  // "about-god"
        return content?.value(ofAttribute: "id")
    }

    func banner() -> String? {  // "About-god.jpg"
        return content?.value(ofAttribute: "banner")
    }
    
    func aemTagIDs() -> Set<String> {    // ["faith-topics:spiritual-growth/prayer", "faith-topics:spiritual-growth/bible", ...]

        let articleElements = content?.filterChildren({ (elem, _) -> Bool in
            return elem.name == "article:aem-tag"
        })
        
        let tags = articleElements?.children.map{ (elem) -> String in
            elem.element?.attribute(by: "id")?.text ?? ""
        }
        
        return Set(tags!)
    }
    
}



// File operating functions

extension XMLArticleCategory {
    
    var baseDir: String {
        var docu = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        docu.appendPathComponent("WebCache")
        docu.appendPathComponent(articleID)
        return docu.path
    }
    
    var dirKeys: [String] {
        
        let keys = Array(self.aemTagIDs()).map {
            $0.replacingOccurrences(of: "/", with: "---")
        }
        
        return keys
    }

    
    func data() -> [ArticleData] {
        
        var arData = [ArticleData]()
        for dir in dirKeys {
            
            let url = URL(fileURLWithPath: baseDir + "/\(dir)/")
            
            do {
                let dirs = try FileManager.default.contentsOfDirectory (at: url, includingPropertiesForKeys: nil,
                                                                        options: [.skipsHiddenFiles])
                print(dirs)
                
                for dir in dirs {
                    let d = dir.appendingPathComponent("properties")
                    let a = try Data(contentsOf: d)
                    var ad = try JSONDecoder().decode(ArticleData.self, from: a)
                    ad.local = dir.appendingPathComponent("page.webarchive")
                    
                    arData.append(ad)
                }
                
            } catch {
                debugPrint("Cannot read local Article archive: \(error.localizedDescription)")
            }
        }
        
        
        // remove duplicates
        let set = Set(arData)
        return Array(Set(arData)).sorted()
    }
    
    
    
}
