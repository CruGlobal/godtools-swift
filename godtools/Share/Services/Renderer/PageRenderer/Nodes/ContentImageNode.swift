//
//  ContentImageNode.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import SWXMLHash

class ContentImageNode: PageXmlNode {
    
    let type: PageXmlNodeType
    let rendererView: RendererNodeView?
    let rendererModel: RendererNodeModel?
    let renderer: NodeRendererType? = nil
    
    var parent: PageXmlNode?
    var children: [PageXmlNode] = Array()
    
    required init(xmlElement: XMLElement, type: PageXmlNodeType) {
    
        self.type = type
        
        let model = ContentImageModel()
        let viewModel = ContentImageViewModel(imageModel: model)
        let view = ContentImageView(viewModel: viewModel)
        
        rendererModel = model
        rendererView = view
    }
    
    var view: UIView {
        return UIView()
    }
    
    func addChildNodeViews(childNodes: [PageXmlNode]) {
        
    }
}
