//
//  RendererPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class RendererPageViewModel: RendererPageViewModelType {
    
    private let pageNode: RendererPageNode
    private let rendererNodeIterator: RendererNodeIterator
    
    let content: ObservableValue<UIScrollView?> = ObservableValue(value: nil)
    
    required init(pageNode: RendererPageNode, rendererNodeIterator: RendererNodeIterator) {
        
        self.pageNode = pageNode
        self.rendererNodeIterator = rendererNodeIterator
        
        for child in pageNode.childNodes {
            
        }
        
        rendererNodeIterator.iterate(node: pageNode, delegate: self)
    }
}

// MARK: - RendererIteratorDelegate

extension RendererPageViewModel: RendererIteratorDelegate {
    
    func rendererIteratorDidIterateNode(rendererIterator: RendererIteratorType, node: BaseRendererNode) {
        
        //let scrollView: UIScrollView = UIScrollView(frame: UIScreen.main.bounds)
        
        print("-> Render node: \(node.name)")
        print("    parent: \(node.parentNode?.name)")
    }
    
    func rendererIteratorError() {
        
    }
}
