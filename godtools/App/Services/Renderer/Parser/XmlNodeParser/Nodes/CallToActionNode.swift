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
    
    required init(xmlElement: XMLElement, position: Int) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        controlColor = attributes["control-color"]?.text
        
        super.init(xmlElement: xmlElement, position: position)
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

// MARK: - MobileContentRenderableNode

extension CallToActionNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
