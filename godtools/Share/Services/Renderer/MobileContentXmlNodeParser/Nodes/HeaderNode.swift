//
//  HeaderNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class HeaderNode: MobileContentXmlNode {
    
    private(set) var number: String?
    private(set) var title: String?
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    override func addChild(childNode: MobileContentXmlNode) {
        
        super.addChild(childNode: childNode)
        
        if let numberNode = childNode as? NumberNode {
            number = numberNode.text
        }
        
        if let titleNode = children.last as? TitleNode {
            title = titleNode.text
        }
    }
}
