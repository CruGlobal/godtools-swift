//
//  ContentTextNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentTextNode: PageXmlNode {
    
    let type: PageXmlNodeType
    let rendererView: RendererNodeView?
    let rendererModel: RendererNodeModel?
    let renderer: NodeRendererType? = nil
    
    var parent: PageXmlNode?
    var children: [PageXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
        
        let text: String?
        
        if let textChild = xmlElement.children.first as? TextElement {
            text = textChild.text
        }
        else {
            text = nil
        }
        
        let model = ContentTextModel(
            text: text
        )
        
        let viewModel = ContentTextViewModel(textModel: model)
        let view = ContentTextView(viewModel: viewModel)
        
        rendererModel = model
        rendererView = view
    }
    
    func addChildNodeViews(childNodes: [PageXmlNode]) {
        
    }
}
