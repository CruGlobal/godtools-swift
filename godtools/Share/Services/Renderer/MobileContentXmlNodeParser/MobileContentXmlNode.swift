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
    
    let name: String
    
    required init(xmlElement: XMLElement) {
        
        name = xmlElement.name
    }
    
    init(name: String) {
        self.name = name
    }
    
    func addChild(childNode: MobileContentXmlNode) {
        
        children.append(childNode)
        
        childNode.parent = self
    }
}
