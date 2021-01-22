//
//  MobileContentXmlNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class MobileContentXmlNode {
    
    private(set) weak var parent: MobileContentXmlNode?
    private(set) var children: [MobileContentXmlNode] = Array()
    
    let xmlElementName: String
    let restrictTo: String?
    let version: String?
    
    required init(xmlElement: XMLElement) {
        
        xmlElementName = xmlElement.name
        
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        restrictTo = attributes["restrictTo"]?.text
        version = attributes["version"]?.text
    }
    
    init(xmlElementName: String) {
        self.xmlElementName = xmlElementName
        restrictTo = nil
        version = nil
    }
    
    func addChild(childNode: MobileContentXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
