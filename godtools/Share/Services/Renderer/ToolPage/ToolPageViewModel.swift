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
    private let manifest: MobileContentXmlManifest
    private let language: LanguageModel
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let followUpsService: FollowUpsService
    private let localizationServices: LocalizationServices
    private let toolPageColors: ToolPageColorsViewModel
    private let page: Int
    private let initialPositions: ToolPageInitialPositions?
        
    private var allCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var visibleCardsViewModels: [ToolPageCardViewModelType] = Array()
    private var hiddenCardsViewModels: [ToolPageCardViewModel] = Array()
    
    private(set) var modalViewModels: [ToolPageModalViewModel] = Array()
    
    private weak var delegate: ToolPageViewModelTypeDelegate?
    
    let contentStackViewModel: ToolPageContentStackViewModel?
    let headerViewModel: ToolPageHeaderViewModel
    let headerTrainingTipViewModel: TrainingTipViewModelType?
    let heroViewModel: ToolPageContentStackViewModel?
    let hidesCards: Bool
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let callToActionViewModel: ToolPageCallToActionViewModel
    let modal: ObservableValue<ToolPageModalViewModel?> = ObservableValue(value: nil)
    
    required init(delegate: ToolPageViewModelTypeDelegate, pageNode: PageNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices, page: Int, initialPositions: ToolPageInitialPositions?) {
                
        let isLastPage: Bool = page >= manifest.pages.count - 1
        
        self.delegate = delegate
        self.pageNode = pageNode
        self.manifest = manifest
        self.language = language
        self.translationsFileCache = translationsFileCache
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.followUpsService = followUpsService
        self.localizationServices = localizationServices
        self.toolPageColors = ToolPageColorsViewModel(pageNode: pageNode, manifest: manifest)
        self.page = page
        self.initialPositions = initialPositions
                
        // content stack
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            
            contentStackViewModel = ToolPageContentStackViewModel(
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
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                defaultButtonBorderColor: nil,
                rootContentStack: nil
            )
        }
        else {
            contentStackViewModel = nil
        }
        
        // header
        headerViewModel = ToolPageHeaderViewModel(
            pageNode: pageNode,
            toolPageColors: toolPageColors,
            fontService: fontService
        )
        
        // headerTrainingTipViewModel
        if let trainingTipId = pageNode.headerNode?.trainingTip, !trainingTipId.isEmpty {
            
            headerTrainingTipViewModel = TrainingTipViewModel(
                trainingTipId: trainingTipId,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentEvents: mobileContentEvents,
                viewType: .upArrow
            )
        }
        else {
            headerTrainingTipViewModel = nil
        }
        
        
        // hero
        if let heroNode = pageNode.heroNode {
            
            heroViewModel = ToolPageContentStackViewModel(
                node: heroNode,
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                localizationServices: localizationServices,
                followUpsService: followUpsService,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                defaultButtonBorderColor: nil,
                rootContentStack: nil
            )
        }
        else {
            heroViewModel = nil
        }
        
        // call to action
        callToActionViewModel = ToolPageCallToActionViewModel(
            pageNode: pageNode,
            toolPageColors: toolPageColors,
            fontService: fontService,
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
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: visibleCardIndex,
                hiddenCardPosition: nil,
                numberOfCards: visibleCards.count,
                toolPageColors: toolPageColors
            )
            
            visibleCardsViewModels.append(cardViewModel)
            allCardsViewModels.append(cardViewModel)
        }
        
        for hiddenCardIndex in 0 ..< hiddenCards.count {
            
            let hiddenCardNode: CardNode = hiddenCards[hiddenCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: hiddenCardNode,
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                cardPosition: allCardsViewModels.count,
                visibleCardPosition: nil,
                hiddenCardPosition: hiddenCardIndex,
                numberOfCards: hiddenCards.count,
                toolPageColors: toolPageColors
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
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentNodeParser: mobileContentNodeParser,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                localizationServices: localizationServices,
                followUpsService: followUpsService,
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
        
        setupBinding()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        mobileContentEvents.contentErrorSignal.removeObserver(self)
        mobileContentEvents.trainingTipTappedSignal.removeObserver(self)
    }
    
    private func setupBinding() {
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            if viewModel.pageNode.listeners.contains(buttonEvent.event) {
                viewModel.delegate?.toolPagePresentedListener(viewModel: viewModel, page: viewModel.page)
            }
        }
        
        mobileContentEvents.contentErrorSignal.addObserver(self) { [weak self] (error: ContentEventError) in
            self?.delegate?.toolPageError(error: error)
        }
        
        mobileContentEvents.trainingTipTappedSignal.addObserver(self) { [weak self] (trainingTipEvent: TrainingTipEvent) in
            self?.delegate?.toolPageTrainingTipTapped(trainingTipId: trainingTipEvent.trainingTipId, tipNode: trainingTipEvent.tipNode)
        }
    }
    
    var backgroundColor: UIColor {
        return toolPageColors.backgroundColor
    }
    
    var backgroundImage: UIImage? {
        if let backgroundResource = pageNode.backgroundImage, let backgroundSrc = manifest.resources[backgroundResource]?.src {
            return translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: backgroundSrc))
        }
        else {
            return nil
        }
    }
    
    var hidesTrainingTip: Bool {
        return pageNode.headerNode?.trainingTip?.isEmpty ?? true
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
        
        if let cardPosition = cardPosition, cardPosition >= 0 && cardPosition < allCardsViewModels.count {
            currentCard.accept(value: AnimatableValue(value: cardPosition, animated: animated))
        }
        else {
            currentCard.accept(value: AnimatableValue(value: nil, animated: animated))
        }
        
        delegate?.toolPageCardChanged(cardPosition: cardPosition)
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
