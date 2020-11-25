//
//  ContentParagraphViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/25/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContentParagraphViewModel: MobileContentViewModelType {
        
    private let node: MobileContentXmlNode
    private let rootContentRenderer: ToolPageContentRenderer
    
    private var content: ToolPageRenderedContent?
    
    required init(node: MobileContentXmlNode, rootContentRenderer: ToolPageContentRenderer) {
        
        self.node = node
        self.rootContentRenderer = rootContentRenderer
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func render(didRenderView: ((_ mobileContentView: MobileContentView) -> Void)) {
        
        self.content = rootContentRenderer.renderContent(
            node: node,
            rootContentRenderer: rootContentRenderer,
            didRenderView: didRenderView
        )
    }
}
