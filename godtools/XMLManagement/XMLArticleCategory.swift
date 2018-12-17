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

    var title: String? {
        return self.label()
    }
    
    init(withXML content: XMLIndexer) {
        super.init()
        self.content = content
        
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
        
        return Set(tags!) ?? Set<String>()
    }
    
    
}

