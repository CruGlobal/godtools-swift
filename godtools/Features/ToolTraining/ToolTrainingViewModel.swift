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
    private let xmlIterator: RendererXmlIterator = RendererXmlIterator()
    
    private var page: Int = 0
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let icon: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(tipXml: Data) {
        
        self.tipXml = tipXml
        
        if let tipsNode = xmlIterator.iterate(xmlData: tipXml, delegate: self) as? RendererTipNode {
            numberOfTipPages.accept(value: tipsNode.childNodes.count)
        }
        
        setPage(page: 0, animated: false)
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
    
    func pageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func pageDidAppear(page: Int) {
        setPage(page: page, animated: true)
    }
}

extension ToolTrainingViewModel: RendererIteratorDelegate {
    
    func rendererIteratorDidIterateNode(rendererIterator: RendererIteratorType, node: BaseRendererNode) {
        
        print("-> Render node: \(node.id)")
        print("    parent: \(node.parentNode?.id)")
    }
    
    func rendererIteratorError() {
        
    }
}
