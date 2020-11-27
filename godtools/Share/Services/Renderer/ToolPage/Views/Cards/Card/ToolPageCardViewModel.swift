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
    private let diContainer: ToolPageDiContainer
    private let cardPosition: Int
    private let visibleCardPosition: Int?
    private let hiddenCardPosition: Int?
    private let numberOfCards: Int
    private let toolPageColors: ToolPageColors
    private let analyticsEventsObjects: [MobileContentAnalyticsEvent]
    
    private weak var delegate: ToolPageCardViewModelTypeDelegate?
    
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    let contentStackViewModel: ToolPageContentStackContainerViewModel
    let isHiddenCard: Bool
    let hidesCardNavigation: Bool
    
    required init(delegate: ToolPageCardViewModelTypeDelegate, cardNode: CardNode, diContainer: ToolPageDiContainer, cardPosition: Int, visibleCardPosition: Int?, hiddenCardPosition: Int?, numberOfCards: Int, toolPageColors: ToolPageColors) {
        
        let isHiddenCard: Bool = cardNode.hidden == "true"
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.diContainer = diContainer
        self.cardPosition = cardPosition
        self.visibleCardPosition = visibleCardPosition
        self.hiddenCardPosition = hiddenCardPosition
        self.numberOfCards = numberOfCards
        self.toolPageColors = toolPageColors
        
        contentStackViewModel = ToolPageContentStackContainerViewModel(
            node: cardNode,
            diContainer: diContainer,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: toolPageColors.cardTextColor,
            defaultTextNodeTextAlignment: nil,
            defaultButtonBorderColor: nil
        )
        
        self.isHiddenCard = isHiddenCard
        hidesCardNavigation = isHiddenCard
        
        if let analyticsEventsNode = cardNode.analyticsEventsNode {
            analyticsEventsObjects = MobileContentAnalyticsEvent.initEvents(eventsNode: analyticsEventsNode, mobileContentAnalytics: diContainer.mobileContentAnalytics)
        }
        else {
            analyticsEventsObjects = []
        }
        
        super.init()
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        
        contentStackViewModel.contentStackRenderer.didRenderTrainingTipsSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
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
        }
    }
    
    var title: String? {
        let title: String? = cardNode.labelNode?.textNode?.text
        return title
    }
    
    var titleColor: UIColor {
        return cardNode.labelNode?.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
    }
    
    var titleFont: UIFont {
        return diContainer.fontService.getFont(size: 19, weight: .regular)
    }
    
    var titleAlignment: NSTextAlignment {
        return diContainer.language.languageDirection == .leftToRight ? .left : .right
    }
    
    var cardPositionLabel: String? {
        let cardPosition: Int = visibleCardPosition ?? 0
        return String(cardPosition+1) + "/" + String(numberOfCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return diContainer.localizationServices.stringForMainBundle(key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return diContainer.localizationServices.stringForMainBundle(key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel {
        return MobileContentBackgroundImageViewModel(backgroundImageNode: cardNode, manifestResourcesCache: diContainer.manifestResourcesCache)
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
        mobileContentViewDidAppear()
    }
    
    func cardWillDisappear() {
        mobileContentViewDidDisappear()
    }
}

// MARK: - MobileContentViewModel

extension ToolPageCardViewModel: MobileContentViewModel {
    
    var analyticsEvents: [MobileContentAnalyticsEvent] {
        return analyticsEventsObjects
    }
    
    var defaultAnalyticsEventsTrigger: AnalyticsEventNodeTrigger {
        return .visible
    }
}
