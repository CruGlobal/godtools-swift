//
//  TractManager.swift
//  godtools
//
//  Created by Devserker on 5/8/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import Foundation
import UIKit
import SWXMLHash

class TractManager: NSObject {

}

extension TractManager {
    
    func loadPagesForResource(resource: String) -> [XMLIndexer] {
        let manifestPath = resource + "-manifest"
        let xmlData = loadXMLFile(manifestPath)
        let manifest = xmlData["manifest"]
        
        var pages = [XMLIndexer]()
        for child in manifest.children {
            if child.element?.name == "page" {
                let page = loadPage(child)
                pages.append(page)
            }
        }
        
        return pages
    }
    
    func loadPage(_ child: XMLIndexer) -> XMLIndexer{
        let resource = child.element?.attribute(by: "id")?.text
        let page = loadXMLFile(resource!)
        return page
    }
    
    func loadXMLFile(_ resource: String) -> XMLIndexer {
        var xml: XMLIndexer?
        if let filepath = Bundle.main.path(forResource: resource, ofType: "xml") {
            do {
                let content = try String(contentsOfFile: filepath)
                
                let regex = try! NSRegularExpression(pattern: "\n", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, content.characters.count)
                let modString = regex.stringByReplacingMatches(in: content, options: [], range: range, withTemplate: "")
                
                xml = SWXMLHash.parse(modString.condenseWhitespace())
            }
            catch {
                // error
            }
        } else {
            // error
        }
        
        return xml!
    }
    
}
