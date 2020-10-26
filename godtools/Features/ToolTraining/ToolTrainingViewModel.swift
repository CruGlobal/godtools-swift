//
//  ToolTrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingViewModel: ToolTrainingViewModelType {
    
    private let tipXml: Data
    private let rendererXmlIterator: RendererXmlIterator
    private let rendererNodeIterator: RendererNodeIterator
    
    private var tipNode: RendererTipNode?
    private var page: Int = 0
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let icon: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(tipXml: Data, rendererXmlIterator: RendererXmlIterator, rendererNodeIterator: RendererNodeIterator) {
        
        self.tipXml = tipXml
        self.rendererXmlIterator = rendererXmlIterator
        self.rendererNodeIterator = rendererNodeIterator
        
        rendererXmlIterator.asyncIterate(xmlData: tipXml) { [weak self] (rootNode: BaseRendererNode?) in
            DispatchQueue.main.async {
                if let tipNode = rootNode as? RendererTipNode {
                    self?.tipNode = tipNode
                    self?.numberOfTipPages.accept(value: tipNode.pages.count)
                    self?.setPage(page: 0, animated: false)
                }
            }
        }
    }
    
    private func setPage(page: Int, animated: Bool) {
        
        self.page = page

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page + 1) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: animated))
        }
    }
    
    func overlayTapped() {
        
    }
    
    func closeTapped() {
        
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= numberOfTipPages.value
        
        if reachedEnd {
            //flowDelegate?.navigate(step: .)
        }
    }
    
    func tipPageWillAppear(page: Int) -> RendererPageViewModelType {
        
        let pageNodes: [RendererPageNode] = tipNode?.pages ?? []
        
        let pageNode: RendererPageNode = pageNodes[page]
        
        return RendererPageViewModel(
            pageNode: pageNode,
            rendererNodeIterator: rendererNodeIterator
        )
    }
    
    func tipPageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func tipPageDidAppear(page: Int) {
        setPage(page: page, animated: true)
    }
}
