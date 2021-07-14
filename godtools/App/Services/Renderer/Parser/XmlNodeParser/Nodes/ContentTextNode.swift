//
//  ContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ContentTextNode: MobileContentXmlNode, ContentTextModelType {
    
    private static let defaultImagePointSize: String = "40"
    
    let endImage: String?
    let endImageSize: String
    let startImage: String?
    let startImageSize: String
    let text: String?
    let textAlign: String?
    let textColor: String?
    let textScale: String?
    let textStyle: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        endImage = attributes["end-image"]?.text
        endImageSize = attributes["end-image-size"]?.text ?? ContentTextNode.defaultImagePointSize
        startImage = attributes["start-image"]?.text
        startImageSize = attributes["start-image-size"]?.text ?? ContentTextNode.defaultImagePointSize
        textAlign = attributes["text-align"]?.text
        textColor = attributes["text-color"]?.text
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
    
    func getTextColor() -> MobileContentRGBAColor? {
        if let stringColor = textColor {
            return MobileContentRGBAColor(stringColor: stringColor)
        }
        return nil
    }
}

extension ContentTextNode {
    var textAlignment: MobileContentTextAlign? {
        return MobileContentTextAlign(rawValue: textAlign ?? "")
    }
}

// MARK: - MobileContentRenderableNode

extension ContentTextNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
