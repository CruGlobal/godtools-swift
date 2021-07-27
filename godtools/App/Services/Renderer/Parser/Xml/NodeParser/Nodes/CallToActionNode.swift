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
        
    private let controlColorString: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        controlColorString = attributes["control-color"]?.text
        
        super.init(xmlElement: xmlElement)
    }
    
    private var textNode: ContentTextNode? {
        return children.first as? ContentTextNode
    }
    
    var text: String? {
        return textNode?.text
    }
    
    func getTextColor() -> MobileContentColor? {
        return textNode?.getTextColor()
    }
    
    func getControlColor() -> MobileContentColor? {
        if let stringColor = controlColorString {
            return MobileContentColor(stringColor: stringColor)
        }
        return nil
    }
}
