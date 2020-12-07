//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageViewModel: NSObject, ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let diContainer: ToolPageDiContainer
    private let toolPageColors: ToolPageColors
    private let page: Int
    private let initialPositions: ToolPageInitialPositions?
        
    private var allCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var visibleCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var hiddenCardsViewModels: [ToolPageCardViewModel] = Array()
    
    private(set) var modalViewModels: [ToolPageModalViewModel] = Array()
    
    private weak var delegate: ToolPageViewModelTypeDelegate?
    
    let contentStackViewModel: ToolPageContentStackContainerViewModel?
    let headerViewModel: ToolPageHeaderViewModel
    let headerTrainingTipViewModel: TrainingTipViewModelType?
    let heroViewModel: ToolPageHeroViewModel?
    let hidesCards: Bool
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let callToActionViewModel: ToolPageCallToActionViewModel
    let modal: ObservableValue<ToolPageModalViewModel?> = ObservableValue(value: nil)
    let hidesHeaderTrainingTip: ObservableValue<Bool> = ObservableValue(value: true)
    let hidesCardJump: ObservableValue<Bool> = ObservableValue(value: true)
    
    required init(delegate: ToolPageViewModelTypeDelegate, pageNode: PageNode, diContainer: ToolPageDiContainer, page: Int, initialPositions: ToolPageInitialPositions?) {
                
        let isLastPage: Bool = page >= diContainer.manifest.pages.count - 1
        
        self.delegate = delegate
        self.pageNode = pageNode
        self.diContainer = diContainer
        self.toolPageColors = ToolPageColors(pageNode: pageNode, manifest: diContainer.manifest)
        self.page = page
        self.initialPositions = initialPositions
                
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
        
        // header
        headerViewModel = ToolPageHeaderViewModel(
            pageNode: pageNode,
            toolPageColors: toolPageColors,
            fontService: diContainer.fontService,
            language: diContainer.language
        )
        
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
        
        // hero
        if let heroNode = pageNode.heroNode {
            
            heroViewModel = ToolPageHeroViewModel(
                heroNode: heroNode,
                diContainer: diContainer,
                toolPageColors: toolPageColors
            )
        }
        else {
            heroViewModel = nil
        }
        
        // call to action
        callToActionViewModel = ToolPageCallToActionViewModel(
            pageNode: pageNode,
            toolPageColors: toolPageColors,
            fontService: diContainer.fontService,
            language: diContainer.language,
            isLastPage: isLastPage
        )
                
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
            self?.delegate?.toolPageError(error: error)
        }
        
        diContainer.mobileContentEvents.trainingTipTappedSignal.addObserver(self) { [weak self] (trainingTipEvent: TrainingTipEvent) in
            self?.delegate?.toolPageTrainingTipTapped(trainingTipId: trainingTipEvent.trainingTipId, tipNode: trainingTipEvent.tipNode)
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
    }
    
    func backgroundImageWillAppear() -> MobileContentBackgroundImageViewModel {
        
        // NOTE: Override page node because we want page background to always fill the device. ~Levi
        
        let backgroundImage: String? = pageNode.backgroundImage ?? diContainer.manifest.attributes.backgroundImage
        
        let backgroundImageNode = MobileContentBackgroundImageNode(
            backgroundImage: backgroundImage,
            backgroundImageAlign: "center",
            backgroundImageScaleType: "fill"
        )
                
        return MobileContentBackgroundImageViewModel(backgroundImageNode: backgroundImageNode, manifestResourcesCache: diContainer.manifestResourcesCache)
    }
    
    func getCurrentPositions() -> ToolPageInitialPositions {
        
        return ToolPageInitialPositions(page: page, card: currentCard.value.value)
    }
    
    func callToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped()
    }
    
    func hiddenCardWillAppear(cardPosition: Int) -> ToolPageCardViewModelType? {
        if cardPosition >= 0 && cardPosition < hiddenCardsViewModels.count {
            return hiddenCardsViewModels[cardPosition]
        }
        return nil
    }
    
    func setCard(cardPosition: Int?, animated: Bool) {
        
        if let currentCardPosition = currentCard.value.value, currentCardPosition != cardPosition {
            allCardsViewModels[currentCardPosition].cardWillDisappear()
        }
        
        if let newCardPosition = cardPosition, newCardPosition != currentCard.value.value {
            allCardsViewModels[newCardPosition].cardWillAppear()
        }
        
        if let cardPosition = cardPosition, cardPosition >= 0 && cardPosition < allCardsViewModels.count {
            currentCard.accept(value: AnimatableValue(value: cardPosition, animated: animated))
        }
        else {
            currentCard.accept(value: AnimatableValue(value: nil, animated: animated))
        }
        
        delegate?.toolPageCardChanged(cardPosition: cardPosition)
        
        if let cardPosition = cardPosition {
            trackCardAnalytics(cardPosition: cardPosition)
        }
    }
    
    func pageDidAppear() {
        heroViewModel?.heroDidAppear()
    }
    
    func pageDidDisappear() {
        heroViewModel?.heroDidDisappear()
    }
    
    func cardBounceAnimationFinished() {
        diContainer.cardJumpService.saveDidShowCardJump()
    }
    
    private func trackCardAnalytics(cardPosition: Int) {
        
        let screenName: String = ToolPageCardAnalyticsScreenName(cardPosition: cardPosition).screenName
        diContainer.analytics.pageViewedAnalytics.trackPageView(screenName: screenName, siteSection: "", siteSubSection: "")
    }
}

// MARK: - ToolPageCardViewModelDelegate

extension ToolPageViewModel: ToolPageCardViewModelTypeDelegate {
    
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
            gotoPreviousCardFromCard(cardPosition: cardPosition)
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
            delegate?.toolPageNextPageTapped()
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
