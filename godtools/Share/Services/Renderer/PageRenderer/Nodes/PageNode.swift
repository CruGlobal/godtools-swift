//
//  PageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class PageNode: RendererXmlNode {
    
    let type: PageXmlNodeType
    
    var parent: RendererXmlNode?
    var children: [RendererXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
    }
}
