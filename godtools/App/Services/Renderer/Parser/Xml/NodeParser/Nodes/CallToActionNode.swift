//
//  CallToActionNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class CallToActionNode: MobileContentXmlNode, CallToActionModelType {
        
    let controlColor: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        controlColor = attributes["control-color"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    private var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
    
    var text: String? {
        return textNode?.text
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        return textNode?.getTextColor()
    }
    
    func getControlColor() -> MobileContentRGBAColor? {
        if let controlColorString = controlColor {
            return MobileContentRGBAColor(stringColor: controlColorString)
        }
        return nil
    }
}
