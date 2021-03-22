//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: ToolPageViewModelType {
    
    private let pageNode: PageNode
    private let pageModel: MobileContentRendererPageModel
    private let toolPageColors: ToolPageColors
    
    required init(pageNode: PageNode, pageModel: MobileContentRendererPageModel, toolPageColors: ToolPageColors) {
        
        self.pageNode = pageNode
        self.pageModel = pageModel
        self.toolPageColors = toolPageColors
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
    }
    
    var bottomViewColor: UIColor {
        
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        let color: UIColor = manifestAttributes.getNavBarColor()?.color ?? manifestAttributes.getPrimaryColor().color
        
        return color.withAlphaComponent(0.1)
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel? {
                    
        let manifestAttributes: MobileContentXmlManifestAttributes = pageModel.manifest.attributes
        
        let backgroundImageNode: BackgroundImageNodeType?
        
        if pageNode.backgroundImageExists {
            backgroundImageNode = pageNode
        }
        else if manifestAttributes.backgroundImageExists {
            backgroundImageNode = manifestAttributes
        }
        else {
            backgroundImageNode = nil
        }
        
        if let backgroundImageNode = backgroundImageNode {
            return MobileContentBackgroundImageViewModel(
                backgroundImageNode: backgroundImageNode,
                manifestResourcesCache: pageModel.resourcesCache,
                languageDirection: pageModel.language.languageDirection
            )
        }
        
        return nil
    }
}

/*
class ToolPageViewModel: NSObject, ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let page: Int
    private let initialPositions: ToolPageInitialPositions?
    private let isLastPage: Bool

    private var allCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var visibleCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var hiddenCardsViewModels: [ToolPageCardViewModel] = Array()
    
    private(set) var modalViewModels: [ToolPageModalViewModel] = Array()
    
    private weak var delegate: ToolPageViewModelTypeDelegate?
    
    let contentStackViewModel: ToolPageContentStackContainerViewModel?
    let headerTrainingTipViewModel: TrainingTipViewModelType?
    let hidesCards: Bool
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let modal: ObservableValue<ToolPageModalViewModel?> = ObservableValue(value: nil)
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(pageNode: PageNode, diContainer: ToolPageDiContainer, page: Int, initialPositions: ToolPageInitialPositions?) {
                
        let isLastPage: Bool = page >= diContainer.manifest.pages.count - 1
        
        self.pageNode = pageNode
        self.diContainer = diContainer
        self.toolPageColors = ToolPageColors(pageNode: pageNode, manifest: diContainer.manifest)
        self.page = page
        self.initialPositions = initialPositions
        self.isLastPage = isLastPage
        
        // content stack
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            
            contentStackViewModel = ToolPageContentStackContainerViewModel(
                node: pageNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                defaultTextNodeTextAlignment: nil,
                defaultButtonBorderColor: nil
            )
        }
        else {
            contentStackViewModel = nil
        }
        
        // headerTrainingTipViewModel
        if let trainingTipId = pageNode.headerNode?.trainingTip, !trainingTipId.isEmpty {
            
            headerTrainingTipViewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                resource: diContainer.resource,
                language: diContainer.language,
                manifest: diContainer.manifest,
                translationsFileCache: diContainer.translationsFileCache,
                mobileContentNodeParser: diContainer.mobileContentNodeParser,
                mobileContentEvents: diContainer.mobileContentEvents,
                viewType: .upArrow,
                viewedTrainingTips: diContainer.viewedTrainingTips
            )
        }
        else {
            headerTrainingTipViewModel = nil
        }
                
        // cards
        hidesCards = pageNode.cardsNode?.cards.isEmpty ?? true
        
        super.init()
        
        let cardNodes: [CardNode] = pageNode.cardsNode?.cards ?? []
        
        var visibleCards: [CardNode] = Array()
        var hiddenCards: [CardNode] = Array()
        
        for cardNode in cardNodes {
            
            if cardNode.hidden != "true" {
                visibleCards.append(cardNode)
            }
            else {
                hiddenCards.append(cardNode)
            }
        }
                
        for visibleCardIndex in 0 ..< visibleCards.count {
            
            let visibleCardNode: CardNode = visibleCards[visibleCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: visibleCardNode,
                diContainer: diContainer,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: visibleCardIndex,
                hiddenCardPosition: nil,
                numberOfCards: visibleCards.count,
                toolPageColors: toolPageColors,
                isLastPage: isLastPage
            )
            
            visibleCardsViewModels.append(cardViewModel)
            allCardsViewModels.append(cardViewModel)
        }
        
        for hiddenCardIndex in 0 ..< hiddenCards.count {
            
            let hiddenCardNode: CardNode = hiddenCards[hiddenCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: hiddenCardNode,
                diContainer: diContainer,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: nil,
                hiddenCardPosition: hiddenCardIndex,
                numberOfCards: hiddenCards.count,
                toolPageColors: toolPageColors,
                isLastPage: isLastPage
            )
            
            hiddenCardsViewModels.append(cardViewModel)
            allCardsViewModels.append(cardViewModel)
        }
        
        // modals
        let modalNodes: [ModalNode] = pageNode.modalsNode?.modals ?? []
        
        for modalNode in modalNodes {
            
            let modalViewModel = ToolPageModalViewModel(
                delegate: self,
                modalNode: modalNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: toolPageColors.primaryTextColor
            )
            
            modalViewModels.append(modalViewModel)
        }
        
        // initialPositions
        if let initialPositions = self.initialPositions {
            if let cardPosition = initialPositions.card, allCardsViewModels.count > 0 {
                setCard(cardPosition: cardPosition, animated: false)
            }
        }
        
        reloadTrainingTipsEnabled(trainingTipsEnabled: diContainer.trainingTipsEnabled)
        
        setupBinding()
        
        hidesCardJump.accept(value: diContainer.cardJumpService.didShowCardJump)
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        diContainer.mobileContentEvents.contentErrorSignal.removeObserver(self)
        diContainer.mobileContentEvents.trainingTipTappedSignal.removeObserver(self)
        diContainer.cardJumpService.didSaveCardJumpShownSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        diContainer.mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            if viewModel.pageNode.listeners.contains(buttonEvent.event) {
                viewModel.delegate?.toolPagePresentedListener(viewModel: viewModel, page: viewModel.page)
            }
        }
        
        diContainer.mobileContentEvents.contentErrorSignal.addObserver(self) { [weak self] (error: ContentEventError) in
            guard let viewModel = self else {
                return
            }
            self?.delegate?.toolPageError(viewModel: viewModel, page: viewModel.page, error: error)
        }
        
        diContainer.mobileContentEvents.trainingTipTappedSignal.addObserver(self) { [weak self] (trainingTipEvent: TrainingTipEvent) in
            guard let viewModel = self else {
                return
            }
            self?.delegate?.toolPageTrainingTipTapped(viewModel: viewModel, page: viewModel.page, trainingTipId: trainingTipEvent.trainingTipId, tipNode: trainingTipEvent.tipNode)
        }
        
        diContainer.cardJumpService.didSaveCardJumpShownSignal.addObserver(self) { [weak self] in
            self?.hidesCardJump.accept(value: true)
        }
    }
    
    private func reloadTrainingTipsEnabled(trainingTipsEnabled: Bool) {
                
        hidesHeaderTrainingTip.accept(value: getHidesHeaderTrainingTip(trainingTipsEnabled: trainingTipsEnabled))
    }
    
    private func getHidesHeaderTrainingTip(trainingTipsEnabled: Bool) -> Bool {
        guard trainingTipsEnabled else {
            return true
        }
        guard let pageHeaderTrainingTip = pageNode.headerNode?.trainingTip else {
            return true
        }
        guard !pageHeaderTrainingTip.isEmpty else {
            return true
        }
        return false
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
    }
    
    var numberOfCards: Int {
        return allCardsViewModels.count
    }
    
    var numberOfVisibleCards: Int {
        return visibleCardsViewModels.count
    }
    
    var numberOfHiddenCards: Int {
        return hiddenCardsViewModels.count
    }
    
    var cardsViewModels: [ToolPageCardViewModelType] {
        return allCardsViewModels
    }s
    
    func getCurrentPositions() -> ToolPageInitialPositions {
        
        return ToolPageInitialPositions(page: page, card: currentCard.value.value)
    }
    
    func callToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped(viewModel: self, page: page)
    }
    
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType? {
        if cardPosition >= 0 && cardPosition < hiddenCardsViewModels.count {
            return hiddenCardsViewModels[cardPosition]
        }
        return nil
    }
    
    func setCard(cardPosition: Int?, animated: Bool) {
        
        if let currentCardPosition = currentCard.value.value, currentCardPosition != cardPosition {
            if currentCardPosition >= 0 && currentCardPosition < allCardsViewModels.count {
                allCardsViewModels[currentCardPosition].cardWillDisappear()
            }
        }
        
        if let newCardPosition = cardPosition, newCardPosition != currentCard.value.value {
            if newCardPosition >= 0 && newCardPosition < allCardsViewModels.count {
                allCardsViewModels[newCardPosition].cardWillAppear()
            }
        }
        
        if let cardPosition = cardPosition, cardPosition >= 0 && cardPosition < allCardsViewModels.count {
            currentCard.accept(value: AnimatableValue(value: cardPosition, animated: animated))
        }
        else {
            currentCard.accept(value: AnimatableValue(value: nil, animated: animated))
        }
        
        delegate?.toolPageCardChanged(viewModel: self, page: page, cardPosition: cardPosition)
        
        if let cardPosition = cardPosition {
            trackCardAnalytics(cardPosition: cardPosition)
        }
    }
    
    func cardBounceAnimationFinished() {
        diContainer.cardJumpService.saveDidShowCardJump()
    }
    
    private func trackCardAnalytics(cardPosition: Int) {
        
        let pageAnalyticsScreenName: String = diContainer.resource.abbreviation + "-" + String(page)
        let screenName: String = pageAnalyticsScreenName + ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        diContainer.analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: "", siteSubSection: "")
    }
}

// MARK: - ToolPageCardViewModelDelegate

extension ToolPageViewModel: ToolPageCardViewModelTypeDelegate {
    
    private func collapseAllCards(animated: Bool) {
        setCard(cardPosition: nil, animated: animated)
    }
    
    private func gotoPreviousCardFromCard(cardPosition: Int) {
        
        let previousCard: Int = cardPosition - 1
        
        if previousCard >= 0 {
            setCard(cardPosition: previousCard, animated: true)
        }
        else {
            setCard(cardPosition: nil, animated: true)
        }
    }
    
    func headerTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
           
        diContainer.cardJumpService.saveDidShowCardJump()
        
        guard let currentCardPosition: Int = currentCard.value.value else {
            setCard(cardPosition: cardPosition, animated: true)
            return
        }
        
        let isShowingCard: Bool = cardPosition <= currentCardPosition
        
        if isShowingCard {
            collapseAllCards(animated: true)
        }
        else {
            setCard(cardPosition: cardPosition, animated: true)
        }
    }
    
    func previousTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
        
        gotoPreviousCardFromCard(cardPosition: cardPosition)
    }
    
    func nextTappedFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
            
        let nextCard: Int = cardPosition + 1
        
        if nextCard <= visibleCardsViewModels.count - 1 {
            setCard(cardPosition: nextCard, animated: true)
        }
        else {
            delegate?.toolPageNextPageTapped(viewModel: self, page: page)
        }
    }
    
    func cardSwipedUpFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
        
        diContainer.cardJumpService.saveDidShowCardJump()
        
        let swipedUpOnCardInVisibleCardStack: Bool = cardPosition < numberOfVisibleCards
        
        guard swipedUpOnCardInVisibleCardStack else {
            return
        }
        
        let nextCard: Int = cardPosition + 1
        
        if nextCard < numberOfVisibleCards {
            setCard(cardPosition: nextCard, animated: true)
        }
    }
    
    func cardSwipedDownFromCard(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
        
        gotoPreviousCardFromCard(cardPosition: cardPosition)
    }
    
    func presentCardListener(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
        
        setCard(cardPosition: cardPosition, animated: true)
    }
    
    func dismissCardListener(cardViewModel: ToolPageCardViewModelType, cardPosition: Int) {
        
        gotoPreviousCardFromCard(cardPosition: cardPosition)
    }
}

// MARK: - ToolPageModalViewModelDelegate

extension ToolPageViewModel: ToolPageModalViewModelDelegate {
    
    func presentModal(modalViewModel: ToolPageModalViewModel) {
        modal.accept(value: modalViewModel)
    }
    
    func dismissModal(modalViewModel: ToolPageModalViewModel) {
        modal.accept(value: nil)
    }
}
*/
