//
//  ModalsNode.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation
import SWXMLHash

class ModalsNode: MobileContentXmlNode, ModalsModelType {
    
    required init(xmlElement: XMLElement) {
    
        super.init(xmlElement: xmlElement)
    }
    
    private var modalNodes: [ModalNode] {
        return children as? [ModalNode] ?? []
    }
}

// MARK: - MobileContentRenderableNode

extension ModalsNode: MobileContentRenderableNode {
    var nodeContentIsRenderable: Bool {
        return true
    }
}
