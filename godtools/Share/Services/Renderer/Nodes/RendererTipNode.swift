//
//  RendererTipNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

class RendererTipNode: BaseRendererNode {
    
    var pages: [RendererPageNode] {
        if let pagesNode = childNodes.first as? RendererPagesNode, let pageNodes = pagesNode.childNodes as? [RendererPageNode] {
            return pageNodes
        }
        return []
    }
}
