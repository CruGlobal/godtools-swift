//
//  ContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentTextNode: MobileContentXmlNode {
    
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
