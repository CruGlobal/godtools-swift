//
//  MobileContentXmlNodeIterator.swift
//  GodTools-Renderer
//
//  Created by Levi Eggert on 10/29/20.
//  Copyright © 2020 Levi Eggert. All rights reserved.
//

import Foundation

class MobileContentXmlNodeIterator {
    
    required init() {
        
    }
    
    func iterate(node: MobileContentXmlNode, didIterateNode: ((_ node: MobileContentXmlNode) -> Void)) {
        
        for childNode in node.children {
            
            iterate(node: childNode, didIterateNode: didIterateNode)
            
            didIterateNode(childNode)
        }
    }
}
