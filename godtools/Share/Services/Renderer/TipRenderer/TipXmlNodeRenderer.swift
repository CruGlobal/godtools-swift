//
//  TipXmlNodeRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TipXmlNodeRenderer {
    
    private let pageRenderer: PageXmlNodeRenderer
    
    required init(pageRenderer: PageXmlNodeRenderer) {
        
        self.pageRenderer = pageRenderer
    }
    
    func render(tipXml: Data) -> [UIView] {
        
        let tipXmlHash: XMLIndexer = SWXMLHash.parse(tipXml)
        
        guard let rootXmlElement = tipXmlHash.element?.children.first as? XMLElement else {
            // Should notifiy of error here.
            return []
        }
        
        guard let pagesXmlElement = recurseForPagesXmlElement(xmlElement: rootXmlElement) else {
            return []
        }
                
        var pages: [UIView] = Array()
        
        for child in pagesXmlElement.children {
            if let pageXmlElement = child as? XMLElement {
                if let pageNode = pageRenderer.renderPageXmlElement(pageXmlElement: pageXmlElement) {
                    let view: UIView = pageRenderer.renderPageNode(page: pageNode)
                    pages.append(view)
                }
            }
        }
        
        return pages
    }
    
    private func recurseForPagesXmlElement(xmlElement: XMLElement) -> XMLElement? {
                
        if xmlElement.name == "pages" {
            return xmlElement
        }
        
        let childElements: [XMLContent] = xmlElement.children
        
        for childElement in childElements {
            if let childXmlElement = childElement as? XMLElement {
                return recurseForPagesXmlElement(xmlElement: childXmlElement)
            }
        }
        
        return nil
    }
}
