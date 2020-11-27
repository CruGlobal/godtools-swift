//
//  ToolPageHeroViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageHeroViewModel: ToolPageContentStackContainerViewModelType {
    
    private let node: MobileContentXmlNode
        
    let contentStackRenderer: ToolPageContentStackRenderer
    
    required init(node: MobileContentXmlNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColors) {
        
        self.node = node
        self.contentStackRenderer = ToolPageContentStackRenderer(
            rootContentStackRenderer: nil,
            diContainer: diContainer,
            node: node,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: nil,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
}
