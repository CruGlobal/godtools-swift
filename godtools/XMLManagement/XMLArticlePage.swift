//
//  XMLArticlePage.swift
//  godtools
//
//  Created by Igor Ostriz on 27/11/2018.
//  Copyright © 2018 Cru. All rights reserved.
//


import Foundation
import SWXMLHash


class XMLArticlePage: NSObject {

    var content: XMLIndexer?
    
    init(withXML content: XMLIndexer) {
        self.content = content
    }

    func aemSources() -> [String?] {
        
        let pagesElements = content?.filterChildren({ (elem, _) -> Bool in
            return elem.name == "article:aem-import"
        })
        
        let srcs = pagesElements?.children.map{ (elem) -> String? in
            elem.element?.attribute(by: "src")?.text
        }
        
        return srcs ?? [String]()
    }
}
