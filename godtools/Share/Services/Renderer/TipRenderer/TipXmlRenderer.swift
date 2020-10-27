//
//  TipXmlRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TipXmlRenderer {
    
    private let pageRenderer: PageXmlRenderer
    
    required init(pageRenderer: PageXmlRenderer) {
        
        self.pageRenderer = pageRenderer
    }
    
    func render(tipXml: Data) -> [PageXmlNode] {
        
        let tipXmlHash: XMLIndexer = SWXMLHash.parse(tipXml)
        
        guard let rootXmlElement = tipXmlHash.element?.children.first as? XMLElement else {
            // Should notifiy of error here.
            return []
        }
        
        guard let pagesXmlElement = recurseForPagesXmlElement(xmlElement: rootXmlElement) else {
            return []
        }
                
        var pageXmlNodes: [PageXmlNode] = Array()
        
        for child in pagesXmlElement.children {
            if let pageXmlElement = child as? XMLElement {
                if let pageXmlNode = pageRenderer.renderPage(pageXmlElement: pageXmlElement) {
                    pageXmlNodes.append(pageXmlNode)
                }
            }
        }
        
        return pageXmlNodes
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
