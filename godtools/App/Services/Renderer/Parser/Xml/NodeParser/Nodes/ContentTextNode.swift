//
//  ContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentTextNode: MobileContentXmlNode, ContentTextModelType {
    
    private static let defaultImagePointSize: String = "40"
    
    private let textAlignString: String?
    private let textColorString: String?
    
    let endImage: String?
    let endImageSize: String
    let startImage: String?
    let startImageSize: String
    let text: String?
    let textScale: String?
    let textStyle: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        endImage = attributes["end-image"]?.text
        endImageSize = attributes["end-image-size"]?.text ?? ContentTextNode.defaultImagePointSize
        startImage = attributes["start-image"]?.text
        startImageSize = attributes["start-image-size"]?.text ?? ContentTextNode.defaultImagePointSize
        textAlignString = attributes["text-align"]?.text
        textColorString = attributes["text-color"]?.text
        textScale = attributes["text-scale"]?.text
        textStyle = attributes["text-style"]?.text
                
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
    
    var textAlignment: MobileContentTextAlignment? {
        
        let defaultTextAlignment: MobileContentTextAlignment? = nil
        
        guard let textAlignString = self.textAlignString?.lowercased() else {
            return defaultTextAlignment
        }
        
        return MobileContentTextAlignment(rawValue: textAlignString) ?? defaultTextAlignment
    }
    
    func getTextColor() -> UIColor? {
        guard let stringColor = textColorString else {
            return nil
        }
        return MobileContentRGBAColor(stringColor: stringColor).color
    }
}
