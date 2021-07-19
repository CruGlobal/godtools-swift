//
//  TitleNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class TitleNode: MobileContentXmlNode, TitleModelType {
        
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    private var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
    
    func getTextColor() -> UIColor? {
        return textNode?.getTextColor()
    }
}
