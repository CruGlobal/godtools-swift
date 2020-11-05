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
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let toolPageViewFactory: ToolPageViewFactory
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    
    private var pageNodes: [PageNode] = Array()
    private var page: Int = 0
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let icon: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(tipXml: Data, mobileContentNodeParser: MobileContentXmlNodeParser, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, toolPageViewFactory: ToolPageViewFactory, localizationServices: LocalizationServices, fontService: FontService) {
        
        self.tipXml = tipXml
        self.mobileContentNodeParser = mobileContentNodeParser
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.toolPageViewFactory = toolPageViewFactory
        self.localizationServices = localizationServices
        self.fontService = fontService
        
        mobileContentNodeParser.asyncParse(xml: tipXml) { [weak self] (node: MobileContentXmlNode?) in
            guard let tipNode = node as? TipNode else {
                return
            }
            
            let pageNodes: [PageNode] = tipNode.pages?.pages ?? []
            self?.pageNodes = pageNodes
            self?.numberOfTipPages.accept(value: pageNodes.count)
            self?.setPage(page: 0, animated: false)
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
    
    func tipPageWillAppear(page: Int) -> ToolPageViewModel {
            
        let pageNode: PageNode = pageNodes[page]
        
        return ToolPageViewModel(
            delegate: self,
            pageNode: pageNode,
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            toolPageViewFactory: toolPageViewFactory,
            localizationServices: localizationServices,
            fontService: fontService,
            hidesBackgroundImage: false
        )
    }
    
    func tipPageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func tipPageDidAppear(page: Int) {
        setPage(page: page, animated: true)
    }
}

// MARK: - ToolPageViewModelDelegate

extension ToolTrainingViewModel: ToolPageViewModelDelegate {
    
    func toolPageNextPageTapped() {
        
    }
}
