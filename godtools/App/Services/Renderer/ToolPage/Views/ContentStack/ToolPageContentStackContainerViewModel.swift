//
//  ToolPageContentStackContainerViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackContainerViewModel: ToolPageContentStackContainerViewModelType {
                
    private let node: MobileContentXmlNode
        
    let contentStackRenderer: ToolPageContentStackRenderer
    
    required init(node: MobileContentXmlNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?) {
        
        self.node = node
        self.contentStackRenderer = ToolPageContentStackRenderer(
            rootContentStackRenderer: nil,
            diContainer: diContainer,
            node: node,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: defaultTextNodeTextAlignment,
            defaultButtonBorderColor: defaultButtonBorderColor
        )
    }
    
    deinit {

    }
}
