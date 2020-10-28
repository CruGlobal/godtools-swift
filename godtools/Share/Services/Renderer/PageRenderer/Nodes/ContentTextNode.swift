//
//  ContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentTextNode: RendererXmlNode {
    
    let type: PageXmlNodeType
    let text: String?
    
    var parent: RendererXmlNode?
    var children: [RendererXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
                
        if let textChild = xmlElement.children.first as? TextElement {
            text = textChild.text
        }
        else {
            text = nil
        }      
    }
}
