//
//  VerticalStackRenderer.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class VerticalStackRenderer: NodeRendererType {
    
    let parent: UIView
    
    required init(parent: UIView) {
        
        self.parent = parent
    }
    
    func render(children: [PageXmlNode]) {
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
       
        var prevFrame: CGRect = .zero
        var totalHeight: CGFloat = 0
        
        for childNode in children {
            
            if let view = childNode.rendererView?.contentView {
                
                parent.addSubview(view)
                
                let viewFrame: CGRect = CGRect(
                    x: 0,
                    y: prevFrame.origin.y + prevFrame.size.height,
                    width: screenWidth,
                    height: view.frame.size.height
                )
                
                view.frame = viewFrame
                
                prevFrame = viewFrame
                
                totalHeight += viewFrame.size.height
            }
        }
        
        var parentFrame: CGRect = parent.frame
        parentFrame.size.width = screenWidth
        parentFrame.size.height = totalHeight
        parent.frame = parentFrame
    }
}
