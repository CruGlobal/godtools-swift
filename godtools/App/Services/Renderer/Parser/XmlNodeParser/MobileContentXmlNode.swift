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
    let position: Int
    
    required init(xmlElement: XMLElement, position: Int) {
        
        self.xmlElement = xmlElement
        self.position = position
        
        super.init()
    }
    
    var xmlElementName: String {
        return xmlElement.name
    }
    
    func addChild(childNode: MobileContentXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
