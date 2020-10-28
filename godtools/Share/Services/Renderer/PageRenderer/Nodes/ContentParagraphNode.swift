//
//  ContentParagraphNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentParagraphNode: RendererXmlNode {
    
    let type: PageXmlNodeType
    
    var parent: RendererXmlNode?
    var children: [RendererXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
    }
}
