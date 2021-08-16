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
        
    private static let defaultImagePointSize: Int32 = 40
    
    private let endImageSizeString: String?
    private let startImageSizeString: String?
    private let textAlignString: String?
    private let textColorString: String?
    private let textScaleString: String?
    private let textStyleString: String?
    
    let endImage: String?
    let startImage: String?
    let text: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        endImage = attributes["end-image"]?.text
        endImageSizeString = attributes["end-image-size"]?.text
        startImage = attributes["start-image"]?.text
        startImageSizeString = attributes["start-image-size"]?.text
        textAlignString = attributes["text-align"]?.text
        textColorString = attributes["text-color"]?.text
        textScaleString = attributes["text-scale"]?.text
        textStyleString = attributes["text-style"]?.text
                
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
    
    var endImageSize: Int32 {
        
        if let sizeString = endImageSizeString, let sizeValue = Int32(sizeString) {
            return sizeValue
        }
        
        return ContentTextNode.defaultImagePointSize
    }
    
    var startImageSize: Int32 {
        
        if let sizeString = startImageSizeString, let sizeValue = Int32(sizeString) {
            return sizeValue
        }
        
        return ContentTextNode.defaultImagePointSize
    }
    
    var textAlignment: MobileContentTextAlignment? {
        
        let defaultTextAlignment: MobileContentTextAlignment? = nil
        
        guard let textAlignString = self.textAlignString?.lowercased() else {
            return defaultTextAlignment
        }
        
        return MobileContentTextAlignment(rawValue: textAlignString) ?? defaultTextAlignment
    }
    
    var textScale: MobileContentTextScale {
        return MobileContentTextScale(textScaleString: textScaleString)
    }
    
    func getTextColor() -> MobileContentColor? {
        guard let stringColor = textColorString else {
            return nil
        }
        return MobileContentColor(stringColor: stringColor)
    }
    
    func getTextStyles() -> [MobileContentTextStyle] {
        
        let defaultTextStyles: [MobileContentTextStyle] = Array()
        
        guard let textStyleString = self.textStyleString else {
            return defaultTextStyles
        }
        
        let textStylesArray: [String] = textStyleString.components(separatedBy: " ")
        let textStyles: [MobileContentTextStyle] = textStylesArray.compactMap({MobileContentTextStyle(rawValue: $0.lowercased())})
            
        guard !textStyles.isEmpty else {
            return defaultTextStyles
        }
        
        return textStyles
    }
}
