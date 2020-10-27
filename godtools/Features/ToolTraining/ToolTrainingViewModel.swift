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
    private let tipRenderer: TipXmlRenderer
    private let pages: [PageXmlNode]
    
    private var page: Int = 0
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let icon: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(tipXml: Data, tipRenderer: TipXmlRenderer) {
        
        self.tipXml = tipXml
        self.tipRenderer = tipRenderer
        
        pages = tipRenderer.render(tipXml: tipXml)
        
        numberOfTipPages.accept(value: pages.count)
        
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
    
    func tipPageWillAppear(page: Int) -> UIView? {
        
        let pageXmlNode: PageXmlNode = pages[page]
        
        return pageXmlNode.rendererView?.contentView
    }
    
    func tipPageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func tipPageDidAppear(page: Int) {
        setPage(page: page, animated: true)
    }
}
