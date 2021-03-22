//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardViewModel: NSObject, ToolPageCardViewModelType {
    
    private let cardNode: CardNode
    private let cardsNode: CardsNode
    private let pageModel: MobileContentRendererPageModel
    private let toolPageColors: ToolPageColors
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    private let cardPosition: Int
    private let numberOfCards: Int
    
    private weak var delegate: ToolPageCardViewModelTypeDelegate?
    
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    let isHiddenCard: Bool
    let hidesCardPositionLabel: Bool
    let hidesPreviousButton: Bool
    let hidesNextButton: Bool
    
    required init(cardNode: CardNode, cardsNode: CardsNode, pageModel: MobileContentRendererPageModel, toolPageColors: ToolPageColors, mobileContentAnalytics: MobileContentAnalytics, fontService: FontService, localizationServices: LocalizationServices) {
                
        let visibleCards: [CardNode] = cardsNode.visibleCards
        
        self.cardNode = cardNode
        self.cardsNode = cardsNode
        self.pageModel = pageModel
        self.toolPageColors = toolPageColors
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardPosition = visibleCards.firstIndex(of: cardNode) ?? 0
        self.numberOfCards = visibleCards.count
        self.isHiddenCard = cardNode.isHidden
        
        if isHiddenCard {
            hidesCardPositionLabel = true
            hidesPreviousButton = true
            hidesNextButton = true
        }
        else {
            let isLastCard: Bool = cardPosition >= numberOfCards - 1
            hidesCardPositionLabel = false
            hidesPreviousButton = false
            hidesNextButton = (pageModel.isLastPage || isLastCard) ? true : false
        }
        
        if let analyticsEventsNode = cardNode.analyticsEventsNode {
            analyticsEventsObjects = MobileContentAnalyticsEvent.initEvents(eventsNode: analyticsEventsNode, mobileContentAnalytics: mobileContentAnalytics)
        }
        else {
            analyticsEventsObjects = []
        }
                
        super.init()
        
        setupBinding()
    }
    
    deinit {
        //print("x deinit: \(type(of: self))")
        
        //diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        //contentStackViewModel.contentStackRenderer.didRenderTrainingTipsSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        /*
        diContainer.mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            if viewModel.cardNode.listeners.contains(buttonEvent.event) {
                self?.delegate?.presentCardListener(cardViewModel: viewModel, cardPosition: viewModel.cardPosition)
            }
            else if viewModel.cardNode.dismissListeners.contains(buttonEvent.event) {
                self?.delegate?.dismissCardListener(cardViewModel: viewModel, cardPosition: viewModel.cardPosition)
            }
        }
        
        contentStackViewModel.contentStackRenderer.didRenderTrainingTipsSignal.addObserver(self) { [weak self] in
            let trainingTipsEnabled: Bool = self?.diContainer.trainingTipsEnabled ?? false
            let showsHeaderTrainingTip: Bool = trainingTipsEnabled
            self?.hidesHeaderTrainingTip.accept(value: !showsHeaderTrainingTip)
        }*/
    }
    
    var title: String? {
        let title: String? = cardNode.labelNode?.textNode?.text
        return title
    }
    
    var titleColor: UIColor {
        return cardNode.labelNode?.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
    }
    
    var titleFont: UIFont {
        return fontService.getFont(size: 19, weight: .regular)
    }
    
    var titleAlignment: NSTextAlignment {
        return pageModel.language.languageDirection == .leftToRight ? .left : .right
    }
    
    var cardPositionLabel: String? {
        return String(cardPosition+1) + "/" + String(numberOfCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return localizationServices.stringForLanguage(language: pageModel.language, key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForLanguage(language: pageModel.language, key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var languageDirectionSemanticContentAttribute: UISemanticContentAttribute {
        return pageModel.languageDirectionSemanticContentAttribute
    }
    
    func setDelegate(delegate: ToolPageCardViewModelTypeDelegate) {
        self.delegate = delegate
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel {
        return MobileContentBackgroundImageViewModel(
            backgroundImageNode: cardNode,
            manifestResourcesCache: pageModel.resourcesCache,
            languageDirection: pageModel.language.languageDirection
        )
    }
    
    func headerTapped() {
        delegate?.headerTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func previousTapped() {
        delegate?.previousTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func nextTapped() {
        delegate?.nextTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func didSwipeCardUp() {
        delegate?.cardSwipedUpFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func didSwipeCardDown() {
        delegate?.cardSwipedDownFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func cardWillAppear() {
        mobileContentDidAppear()
    }
    
    func cardWillDisappear() {
        mobileContentDidDisappear()
    }
}

// MARK: - MobileContentViewModelType

extension ToolPageCardViewModel: MobileContentViewModelType {
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
