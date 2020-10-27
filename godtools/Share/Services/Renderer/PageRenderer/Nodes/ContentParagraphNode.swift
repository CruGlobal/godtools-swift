//
//  ContentParagraphNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentParagraphNode: PageXmlNode {
    
    let type: PageXmlNodeType
    let rendererView: RendererNodeView?
    let rendererModel: RendererNodeModel?
    let renderer: NodeRendererType?
    
    var parent: PageXmlNode?
    var children: [PageXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
        
        let model = ContentParagraphModel()
        let viewModel = ContentParagraphViewModel(paragraphModel: model)
        let view = ContentParagraphView(viewModel: viewModel)
        
        rendererModel = model
        rendererView = view
        renderer = VerticalStackRenderer(parent: view.contentView)
    }
    
    var view: UIView {
        return UIView()
    }
    
    func addChildNodeViews(childNodes: [PageXmlNode]) {
        
    }
}
