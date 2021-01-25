//
//  ToolTrainingViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingViewModel: NSObject, ToolTrainingViewModelType {
    
    private let resource: ResourceModel
    private let language: LanguageModel
    private let primaryLanguage: LanguageModel
    private let languageDirectionSemanticContentAttribute: UISemanticContentAttribute
    private let trainingTipId: String
    private let tipNode: TipNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentNodeParser: MobileContentXmlNodeParser
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let analytics: AnalyticsContainer
    private let fontService: FontService
    private let followUpsService: FollowUpsService
    private let localizationServices: LocalizationServices
    private let cardJumpService: CardJumpService
    private let viewedTrainingTips: ViewedTrainingTipsService
    private let toolPage: Int
    
    private var pageNodes: [PageNode] = Array()
    private var page: Int = 0
    
    private weak var flowDelegate: FlowDelegate?
    
    let progress: ObservableValue<AnimatableValue<CGFloat>> = ObservableValue(value: AnimatableValue(value: 0, animated: false))
    let trainingTipBackgroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let trainingTipForegroundImage: ObservableValue<UIImage?> = ObservableValue(value: nil)
    let title: ObservableValue<String> = ObservableValue(value: "")
    let continueButtonTitle: ObservableValue<String> = ObservableValue(value: "")
    let numberOfTipPages: ObservableValue<Int> = ObservableValue(value: 0)
    
    required init(flowDelegate: FlowDelegate, resource: ResourceModel, language: LanguageModel, primaryLanguage: LanguageModel, trainingTipId: String, tipNode: TipNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, analytics: AnalyticsContainer, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices, cardJumpService: CardJumpService, viewedTrainingTips: ViewedTrainingTipsService, toolPage: Int) {
        
        self.flowDelegate = flowDelegate
        self.resource = resource
        self.language = language
        self.primaryLanguage = primaryLanguage
        self.trainingTipId = trainingTipId
        self.tipNode = tipNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentNodeParser = mobileContentNodeParser
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.analytics = analytics
        self.fontService = fontService
        self.followUpsService = followUpsService
        self.localizationServices = localizationServices
        self.cardJumpService = cardJumpService
        self.viewedTrainingTips = viewedTrainingTips
        self.toolPage = toolPage
        
        switch primaryLanguage.languageDirection {
        case .leftToRight:
            languageDirectionSemanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            languageDirectionSemanticContentAttribute = .forceRightToLeft
        }
        
        super.init()
        
        let startingPage: Int = 0
        let pageNodes: [PageNode] = tipNode.pages?.pages ?? []
        self.pageNodes = pageNodes
        numberOfTipPages.accept(value: pageNodes.count)
        setPage(page: startingPage, animated: false)
        tipPageDidChange(page: startingPage)
        tipPageDidAppear(page: startingPage)
        
        reloadTitleAndTipIcon(
            tipNode: tipNode,
            trainingTipViewed: viewedTrainingTips.containsViewedTrainingTip(viewedTrainingTip: ViewedTrainingTip(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id))
        )
        
        setupBinding()
    }
    
    deinit {
        mobileContentEvents.urlButtonTappedSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        mobileContentEvents.urlButtonTappedSignal.addObserver(self) { [weak self] (urlButtonEvent: UrlButtonEvent) in
            guard let url = URL(string: urlButtonEvent.url) else {
                return
            }
            self?.flowDelegate?.navigate(step: .urlLinkTappedFromToolTraining(url: url))
        }
    }
    
    private func setPage(page: Int, animated: Bool) {
        
        self.page = page
        
        let continueTitle: String
        if page < (numberOfTipPages.value - 1) {
            continueTitle = localizationServices.stringForMainBundle(key: "card_status2")
        }
        else {
            continueTitle = localizationServices.stringForMainBundle(key: "close")
        }
        continueButtonTitle.accept(value: continueTitle)

        if numberOfTipPages.value > 0 {
            let trainingProgress: CGFloat = CGFloat(page + 1) / CGFloat(numberOfTipPages.value)
            progress.accept(value: AnimatableValue(value: trainingProgress, animated: animated))
        }
    }
    
    private func reloadTitleAndTipIcon(tipNode: TipNode, trainingTipViewed: Bool) {
        
        if let tipTypeValue = tipNode.tipType, let trainingTipType = TrainingTipType(rawValue: tipTypeValue) {
        
            let tipBackgroundImageName: String = trainingTipViewed ? "training_tip_red_square_bg" : "training_tip_square_bg"
            let tipImageName: String
            let localizedTipTitle: String
            
            switch trainingTipType {
            case .ask:
                tipImageName = trainingTipViewed ? "training_tip_ask_filled_red" : "training_tip_ask"
                localizedTipTitle = "training_tip_ask"
            case .consider:
                tipImageName = trainingTipViewed ? "training_tip_consider_filled_red" : "training_tip_consider"
                localizedTipTitle = "training_tip_consider"
            case .prepare:
                tipImageName = trainingTipViewed ? "training_tip_prepare_filled_red" : "training_tip_prepare"
                localizedTipTitle = "training_tip_prepare"
            case .quote:
                tipImageName = trainingTipViewed ? "training_tip_quote_filled_red" : "training_tip_quote"
                localizedTipTitle = "training_tip_quote"
            case .tip:
                tipImageName = trainingTipViewed ? "training_tip_tip_filled_red" : "training_tip_tip"
                localizedTipTitle = "training_tip_tip"
            }
            
            let tipTitle: String = localizationServices.stringForMainBundle(key: localizedTipTitle)
            
            trainingTipBackgroundImage.accept(value: UIImage(named: tipBackgroundImageName))
            trainingTipForegroundImage.accept(value: UIImage(named: tipImageName))
            title.accept(value: tipTitle)
        }
    }
    
    func viewLoaded() {
        viewedTrainingTips.storeViewedTrainingTip(viewedTrainingTip: ViewedTrainingTip(trainingTipId: trainingTipId, resourceId: resource.id, languageId: language.id))
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
            flowDelegate?.navigate(step: .closeTappedFromToolTraining)
        }
    }
    
    func tipPageWillAppear(page: Int) -> MobileContentStackView? {
        
        // TODO: I should create a trainingContentRenderer and subclass ToolPageContentStackRenderer and for pageNode provide MobileContentStackView. ~Levi
        
        let pageNode: PageNode = pageNodes[page]
        
        let toolPageDiContainer = ToolPageDiContainer(
            manifest: manifest,
            resource: resource,
            language: language,
            primaryLanguage: primaryLanguage,
            languageDirectionSemanticContentAttribute: languageDirectionSemanticContentAttribute,
            translationsFileCache: translationsFileCache,
            mobileContentNodeParser: mobileContentNodeParser,
            mobileContentAnalytics: mobileContentAnalytics,
            mobileContentEvents: mobileContentEvents,
            analytics: analytics,
            fontService: fontService,
            followUpsService: followUpsService,
            localizationServices: localizationServices,
            cardJumpService: cardJumpService,
            viewedTrainingTips: viewedTrainingTips,
            trainingTipsEnabled: true
        )
        
        // TODO: Need to keep a strong reference to the renderer otherwise we lose our event handlers. ~Levi
        
        let contentRenderer = ToolPageContentStackRenderer(
            rootContentStackRenderer: nil,
            diContainer: toolPageDiContainer,
            node: pageNode,
            toolPageColors: ToolPageColors(pageNode: pageNode, manifest: manifest),
            defaultTextNodeTextColor: nil,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
        
        return contentRenderer.render() as? MobileContentStackView
    }
    
    func tipPageDidChange(page: Int) {
        setPage(page: page, animated: true)
    }
    
    func tipPageDidAppear(page: Int) {
        setPage(page: page, animated: true)
        
        let tipPage: Int = page
        let analyticsScreenName: String = "\(resource.abbreviation)-tip-\(trainingTipId)-\(tipPage)"
        analytics.pageViewedAnalytics.trackPageView(screenName: analyticsScreenName, siteSection: "", siteSubSection: "")
    }
}

// MARK: - ToolPageViewModelTypeDelegate

extension ToolTrainingViewModel: ToolPageViewModelTypeDelegate {
    
    func toolPagePresentedListener(viewModel: ToolPageViewModelType, page: Int) {
        
    }
    
    func toolPageTrainingTipTapped(viewModel: ToolPageViewModelType, page: Int, trainingTipId: String, tipNode: TipNode) {
        
    }
    
    func toolPageCardChanged(viewModel: ToolPageViewModelType, page: Int, cardPosition: Int?) {
        
    }
    
    func toolPageNextPageTapped(viewModel: ToolPageViewModelType, page: Int) {
        
    }
    
    func toolPageError(viewModel: ToolPageViewModelType, page: Int, error: ContentEventError) {
        
    }
}
