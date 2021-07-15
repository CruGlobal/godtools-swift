//
//  TrainingTipNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/12/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class TrainingTipNode: MobileContentXmlNode, TrainingTipModelType {
    
    let id: String?
    
    required init(xmlElement: XMLElement) {
    
        let attributes: [String: XMLAttribute] = xmlElement.allAttributes
        
        id = attributes["id"]?.text
        
        super.init(xmlElement: xmlElement)
    }
}

// MARK: - MobileContentRenderableNode

extension TrainingTipNode: MobileContentRenderableNode {
    
    var nodeContentIsRenderable: Bool {
        return true
    }
}
