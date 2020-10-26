//
//  RendererContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class RendererContentTextNode: BaseRendererNode {
    
    let text: String?
    
    required init(xmlElement: XMLElement) {
        
        if let textChild = xmlElement.children.first as? TextElement {
            text = textChild.text
        }
        else {
            text = nil
        }
        
        super.init(xmlElement: xmlElement)
    }
}
