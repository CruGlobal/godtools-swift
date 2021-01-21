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
    
    let restrictTo: String?
    let text: String?
    let textAlign: String?
    let textColor: String?
    let textScale: String?
    let textStyle: String?
    let version: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        restrictTo = attributes["restrictTo"]?.text
        textAlign = attributes["text-align"]?.text
        textColor = attributes["text-color"]?.text
        textScale = attributes["text-scale"]?.text
        textStyle = attributes["text-style"]?.text
        version = attributes["version"]?.text
                
        if xmlElement.text.trimmingCharacters(in: .whitespaces) != "" {
            text = xmlElement.text
        }
        else if let childElementText = (xmlElement.children.first as? TextElement)?.text, childElementText.trimmingCharacters(in: .whitespaces) != "" {
            text = childElementText
        }
        else {
            text = nil
        }
        
        super.init(xmlElement: xmlElement)
    }
    
    func getTextColor() -> MobileContentRGBAColor? {
        if let stringColor = textColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
}
