//
//  ModalNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ModalNode: MobileContentXmlNode, ModalModelType {
    
    let dismissListeners: [MultiplatformEventId]
    let listeners: [MultiplatformEventId]
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        //let dismissListenerNames: [String] = attributes["dismiss-listeners"]?.text.components(separatedBy: " ") ?? []
        dismissListeners = Array()
        
        //let listenerNames: [String] = attributes["listeners"]?.text.components(separatedBy: " ") ?? []
        listeners = Array()
        
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableModelContainer

extension ModalNode: MobileContentRenderableModelContainer {
    
    var buttonColor: MobileContentColor? {
        return MobileContentColor(stringColor: "rgba(255,255,255,1)")
    }
    
    var buttonStyle: MobileContentButtonStyle? {
        return .outlined
    }
    
    var primaryColor: MobileContentColor? {
        return MobileContentColor(stringColor: "rgba(0,0,0,0)")
    }
    
    var primaryTextColor: MobileContentColor? {
        return MobileContentColor(stringColor: "rgba(255,255,255,1)")
    }
    
    var textAlignment: MobileContentTextAlignment? {
        return .center
    }
    
    var textColor: MobileContentColor? {
        return MobileContentColor(stringColor: "rgba(255,255,255,1)")
    }
}
