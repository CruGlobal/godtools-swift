//
//  MobileContentXmlNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import Foundation
import SWXMLHash

class MobileContentXmlNode: NSObject {
    
    private(set) weak var parent: MobileContentXmlNode?
    private(set) var children: [MobileContentXmlNode] = Array()
    
    let xmlElement: XMLElement
    
    required init(xmlElement: XMLElement) {
        
        self.xmlElement = xmlElement
        
        super.init()
    }
    
    var xmlElementName: String {
        return xmlElement.name
    }
    
    var restrictTo: String? {
        return xmlElement.allAttributes["restrictTo"]?.text
    }
    
    var version: String? {
        return xmlElement.allAttributes["version"]?.text
    }
    
    func addChild(childNode: MobileContentXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
