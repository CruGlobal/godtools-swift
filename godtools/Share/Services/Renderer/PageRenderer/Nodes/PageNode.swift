//
//  PageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class PageNode: PageXmlNode {
    
    let type: PageXmlNodeType
    let rendererView: RendererNodeView?
    let rendererModel: RendererNodeModel?
    let renderer: NodeRendererType?
    
    var parent: PageXmlNode?
    var children: [PageXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
        
        let model = PageModel()
        let viewModel = PageViewModel(pageModel: model)
        let view = PageView(viewModel: viewModel)
        
        rendererModel = model
        rendererView = view
        renderer = VerticalStackRenderer(parent: view.contentView)
    }
    
    func addChildNodeViews(childNodes: [PageXmlNode]) {
        
    }
}
