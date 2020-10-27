//
//  PageRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class PageRenderer: NodeRendererType {
    
    let parent: UIView
    
    required init(parent: UIView) {
        
        self.parent = parent
    }
    
    func render(children: [PageXmlNode]) {
        
        for childNode in children {
            if let view = childNode.rendererView?.contentView {
                parent.addSubview(view)
            }
        }
    }
}
