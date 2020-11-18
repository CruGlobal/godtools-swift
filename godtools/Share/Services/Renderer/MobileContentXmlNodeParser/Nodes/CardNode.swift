//
//  CardNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CardNode: MobileContentXmlNode, BackgroundImageNodeType {
        
    let backgroundImage: String?
    let backgroundImageAlign: String
    let backgroundImageScaleType: String
    let dismissListeners: [String]
    let hidden: String?
    let listeners: [String]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        backgroundImage = attributes["background-image"]?.text
        backgroundImageAlign = attributes["background-image-align"]?.text ?? "center"
        backgroundImageScaleType = attributes["background-image-scale-type"]?.text ?? "fill-x"
        dismissListeners = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        hidden = attributes["hidden"]?.text
        listeners = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        
        super.init(xmlElement: xmlElement)
    }
    
    var labelNode: LabelNode? {
        return children.first as? LabelNode
    }
}
