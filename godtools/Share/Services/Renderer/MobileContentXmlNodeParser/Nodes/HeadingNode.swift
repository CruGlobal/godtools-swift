//
//  HeadingNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/2/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class HeadingNode: MobileContentXmlNode {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    var text: String? {
        if let textNode = children.first as? ContentTextNode {
            return textNode.text
        }
        
        return nil
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        if let textNode = children.first as? ContentTextNode {
            return textNode.getTextColor()
        }
        
        return nil
    }
}
