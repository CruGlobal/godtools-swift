//
//  PagesNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class PagesNode: MobileContentXmlNode {
        
    required init(xmlElement: XMLElement, position: Int) {
    
        super.init(xmlElement: xmlElement, position: position)
    }
    
    var pages: [PageNode] {
        return children as? [PageNode] ?? []
    }
}
