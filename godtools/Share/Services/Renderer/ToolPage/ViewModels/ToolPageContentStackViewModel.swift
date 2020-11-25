//
//  ToolPageContentStackViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/30/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageContentStackViewModel: MobileContentViewModelType {
                
    private let node: MobileContentXmlNode
    private let contentRenderer: ToolPageContentRenderer
    
    private var content: ToolPageRenderedContent?
    
    required init(node: MobileContentXmlNode, diContainer: ToolPageDiContainer, toolPageColors: ToolPageColorsViewModel, defaultTextNodeTextColor: UIColor?, defaultTextNodeTextAlignment: NSTextAlignment?, defaultButtonBorderColor: UIColor?) {
        
        self.node = node
        self.contentRenderer = ToolPageContentRenderer(
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: defaultTextNodeTextColor,
            defaultTextNodeTextAlignment: defaultTextNodeTextAlignment,
            defaultButtonBorderColor: defaultButtonBorderColor
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func render(didRenderView: ((_ mobileContentView: MobileContentView) -> Void)) {
        
        self.content = contentRenderer.renderContent(
            node: node,
            rootContentRenderer: contentRenderer,
            didRenderView: didRenderView
        )
    }
}
