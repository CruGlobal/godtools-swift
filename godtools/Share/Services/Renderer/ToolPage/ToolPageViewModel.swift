//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelDelegate: class {
    
    func toolPagePresented(viewModel: ToolPageViewModel, page: Int)
    func toolPageNextPageTapped()
    func toolPageError(error: ContentEventError)
}

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
        
    private var hiddenCardsViewModels: [ToolPageCardViewModel] = Array()
    
    private(set) var cardsViewModels: [ToolPageCardViewModelType] = Array()
    private(set) var modalViewModels: [ToolPageModalViewModel] = Array()
    
    private weak var delegate: ToolPageViewModelDelegate?
    
    let backgroundColor: UIColor
    let backgroundImage: UIImage?
    let contentStackViewModel: ToolPageContentStackViewModel?
    let headerViewModel: ToolPageHeaderViewModel
    let heroViewModel: ToolPageContentStackViewModel?
    let hidesCards: Bool
    let currentCard: ObservableValue<AnimatableValue<Int?>> = ObservableValue(value: AnimatableValue(value: nil, animated: false))
    let hiddenCard: ObservableValue<ToolPageCardViewModel?> = ObservableValue(value: nil)
    let callToActionViewModel: ToolPageCallToActionViewModel
    let modal: ObservableValue<ToolPageModalViewModel?> = ObservableValue(value: nil)
    
    required init(delegate: ToolPageViewModelDelegate, pageNode: PageNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices, page: Int, initialPositions: ToolPageInitialPositions?) {
                
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
        
        backgroundColor = toolPageColors.backgroundColor
        
        // background image
        if let backgroundResource = pageNode.backgroundImage, let backgroundSrc = manifest.resources[backgroundResource]?.src {
            backgroundImage = translationsFileCache.getImage(location: SHA256FileLocation(sha256WithPathExtension: backgroundSrc))
        }
        else {
            backgroundImage = nil
        }
        
        // content stack
        let firstNodeIsContentParagraph: Bool = pageNode.children.first is ContentParagraphNode
        
        if firstNodeIsContentParagraph {
            
            contentStackViewModel = ToolPageContentStackViewModel(
                node: pageNode,
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                localizationServices: localizationServices,
                followUpsService: followUpsService,
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
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
            fontService: fontService
        )
        
        // hero
        if let heroNode = pageNode.heroNode {
            
            heroViewModel = ToolPageContentStackViewModel(
                node: heroNode,
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                localizationServices: localizationServices,
                followUpsService: followUpsService,
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                defaultButtonBorderColor: nil
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
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                cardPosition: visibleCardIndex,
                totalCards: visibleCards.count,
                toolPageColors: toolPageColors
            )
            
            cardsViewModels.append(cardViewModel)
        }
        
        for hiddenCardIndex in 0 ..< hiddenCards.count {
            
            let hiddenCardNode: CardNode = hiddenCards[hiddenCardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: hiddenCardNode,
                manifest: manifest,
                language: language,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                followUpsService: followUpsService,
                localizationServices: localizationServices,
                cardPosition: hiddenCardIndex,
                totalCards: hiddenCards.count,
                toolPageColors: toolPageColors
            )
            
            hiddenCardsViewModels.append(cardViewModel)
        }
        
        if let initialPositions = self.initialPositions, visibleCards.count > 0 {
            currentCard.accept(value: AnimatableValue(value: initialPositions.card, animated: false))
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
        
        addObservers()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeObservers()
    }
    
    private func addObservers() {
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            if viewModel.pageNode.listeners.contains(buttonEvent.event) {
                viewModel.delegate?.toolPagePresented(viewModel: viewModel, page: viewModel.page)
            }
        }
        
        mobileContentEvents.contentErrorSignal.addObserver(self) { [weak self] (error: ContentEventError) in
            self?.delegate?.toolPageError(error: error)
        }
    }
    
    private func removeObservers() {
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
        mobileContentEvents.contentErrorSignal.removeObserver(self)
    }
    
    func getCurrentPositions() -> ToolPageInitialPositions {
        return ToolPageInitialPositions(card: currentCard.value.value)
    }
    
    func handleCallToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped()
    }
    
    private func setCardPosition(cardPosition: Int?, animated: Bool) {
        currentCard.accept(value: AnimatableValue(value: cardPosition, animated: animated))
    }
}

// MARK: - ToolPageCardViewModelDelegate

extension ToolPageViewModel: ToolPageCardViewModelDelegate {
    
    private func gotoPreviousCardFromCard(cardPosition: Int) {
        
        let previousCard: Int = cardPosition - 1
        
        if previousCard >= 0 {
            setCardPosition(cardPosition: previousCard, animated: true)
        }
        else {
            setCardPosition(cardPosition: nil, animated: true)
        }
    }
    
    func headerTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
             
        if !cardViewModel.isHiddenCard {
            
            let isShowingCard: Bool = cardPosition == currentCard.value.value
            
            if !isShowingCard {
                setCardPosition(cardPosition: cardPosition, animated: true)
            }
            else {
                
                gotoPreviousCardFromCard(cardPosition: cardPosition)
            }
        }
        else {
            hiddenCard.accept(value: nil)
        }
    }
    
    func previousTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
        
        gotoPreviousCardFromCard(cardPosition: cardPosition)
    }
    
    func nextTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
                
        let nextCard: Int = cardPosition + 1
        
        if nextCard <= cardsViewModels.count - 1 {
            setCardPosition(cardPosition: nextCard, animated: true)
        }
        else {
            delegate?.toolPageNextPageTapped()
        }
    }
    
    func cardSwipedUpFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
        
        guard !cardViewModel.isHiddenCard else {
            return
        }
        
        let isShowingCard: Bool = currentCard.value.value == cardPosition
        
        if isShowingCard {
            
            let nextCard: Int = cardPosition + 1
            
            if nextCard <= cardsViewModels.count - 1 {
                setCardPosition(cardPosition: nextCard, animated: true)
            }
        }
        else {
            setCardPosition(cardPosition: cardPosition, animated: true)
        }
    }
    
    func cardSwipedDownFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
        
        if !cardViewModel.isHiddenCard {
            
            let isShowingCard: Bool = currentCard.value.value == cardPosition
            
            if isShowingCard {
                gotoPreviousCardFromCard(cardPosition: cardPosition)
            }
        }
        else {
            hiddenCard.accept(value: nil)
        }
    }
    
    func presentCardListener(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
        
        if !cardViewModel.isHiddenCard {
            setCardPosition(cardPosition: cardPosition, animated: true)
        }
        else if cardViewModel.isHiddenCard {
            hiddenCard.accept(value: cardViewModel)
        }
    }
    
    func dismissCardListener(cardViewModel: ToolPageCardViewModel, cardPosition: Int) {
        
        if !cardViewModel.isHiddenCard {
            gotoPreviousCardFromCard(cardPosition: cardPosition)
        }
        else {
            hiddenCard.accept(value: nil)
        }
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
