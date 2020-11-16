//
//  ToolTrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingViewModel: ToolTrainingViewModelType {
    
    private let language: LanguageModel
    private let trainingTipId: String
    private let tipNode: TipNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let followUpsService: FollowUpsService
    private let localizationServices: LocalizationServices
    
    private var pageNodes: [PageNode] = Array()
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate, language: LanguageModel, trainingTipId: String, tipNode: TipNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices) {
        
        self.flowDelegate = flowDelegate
        self.language = language
        self.trainingTipId = trainingTipId
        self.tipNode = tipNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.followUpsService = followUpsService
        self.localizationServices = localizationServices
        
        let pageNodes: [PageNode] = tipNode.pages?.pages ?? []
        self.pageNodes = pageNodes
        numberOfTipPages.accept(value: pageNodes.count)
        setPage(page: 0, animated: false)
        
        reloadTitleAndTipIcon(tipNode: tipNode)
    }
    
    private func setPage(page: Int, animated: Bool) {
        
        self.page = page

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page + 1) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: animated))
        }
    }
    
    private func reloadTitleAndTipIcon(tipNode: TipNode) {
        
        if let tipTypeValue = tipNode.tipType, let trainingTipType = TrainingTipType(rawValue: tipTypeValue) {
            
            trainingTipBackgroundImage.accept(value: UIImage(named: "training_tip_red_square_bg"))
            
            let imageName: String
            let trainingTipTitle: String
            
            switch trainingTipType {
            case .ask:
                imageName = "training_tip_ask_filled_red"
                trainingTipTitle = "Ask"
            case .consider:
                imageName = "training_tip_consider_filled_red"
                trainingTipTitle = "Consider"
            case .prepare:
                imageName = "training_tip_prepare_filled_red"
                trainingTipTitle = "Prepare"
            case .quote:
                imageName = "training_tip_quote_filled_red"
                trainingTipTitle = "Quote"
            case .tip:
                imageName = "training_tip_tip_filled_red"
                trainingTipTitle = "Tip"
            }
            
            trainingTipForegroundImage.accept(value: UIImage(named: imageName))
            title.accept(value: trainingTipTitle)
        }
    }
    
    func overlayTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolTraining)
    }
    
    func closeTapped() {
        flowDelegate?.navigate(step: .closeTappedFromToolTraining)
    }
    
    func continueTapped() {
        
        let nextPage: Int = page + 1
        let reachedEnd: Bool = nextPage >= numberOfTipPages.value
        
        if reachedEnd {
            //flowDelegate?.navigate(step: .)
        }
    }
    
    func tipPageWillAppear(page: Int) -> ToolPageContentStackViewModel {
            
        let pageNode: PageNode = pageNodes[page]
        
        return ToolPageContentStackViewModel(
            node: pageNode,
            manifest: manifest,
            language: language,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            localizationServices: localizationServices,
            followUpsService: followUpsService,
            toolPageColors: ToolPageColorsViewModel(pageNode: pageNode, manifest: manifest),
            defaultTextNodeTextColor: nil,
            defaultButtonBorderColor: nil,
            rootContentStack: nil
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
    
    func toolPagePresented(viewModel: ToolPageViewModel, page: Int) {
        
    }
    
    func toolPageTrainingTipTapped(trainingTipId: String, tipNode: TipNode) {
        
    }
    
    func toolPageNextPageTapped() {
        
    }
    
    func toolPageError(error: ContentEventError) {
        
    }
}
