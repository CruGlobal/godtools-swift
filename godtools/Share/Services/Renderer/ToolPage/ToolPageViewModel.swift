//
//  ToolPageViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageViewModelDelegate: class {
    
    func toolPageNextPageTapped()
}

class ToolPageViewModel: NSObject, ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentAnalytics: MobileContentAnalytics
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let toolPageColors: ToolPageColorsViewModel
        
    private(set) var cardsViewModels: [ToolPageCardViewModelType] = Array()
    
    private weak var delegate: ToolPageViewModelDelegate?
    
    let backgroundImage: UIImage?
    let hidesBackgroundImage: Bool
    let contentStackViewModel: ToolPageContentStackViewModel?
    let headerViewModel: ToolPageHeaderViewModel
    let heroViewModel: ToolPageContentStackViewModel?
    let hidesCards: Bool
    let currentCard: ObservableValue<Int?> = ObservableValue(value: nil)
    let callToActionViewModel: ToolPageCallToActionViewModel
    
    required init(delegate: ToolPageViewModelDelegate, pageNode: PageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, hidesBackgroundImage: Bool) {
                
        self.delegate = delegate
        self.pageNode = pageNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentAnalytics = mobileContentAnalytics
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.toolPageColors = ToolPageColorsViewModel(pageNode: pageNode, manifest: manifest)
        self.hidesBackgroundImage = hidesBackgroundImage
        
        // background image
        if !hidesBackgroundImage, let backgroundResource = pageNode.backgroundImage, let backgroundSrc = manifest.resources[backgroundResource]?.src {
            
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
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil
            )
        }
        else {
            contentStackViewModel = nil
        }
        
        // header
        headerViewModel = ToolPageHeaderViewModel(
            pageNode: pageNode,
            backgroundColor: toolPageColors.primaryColor,
            primaryTextColor: toolPageColors.primaryTextColor,
            fontService: fontService
        )
        
        // hero
        if let heroNode = pageNode.heroNode {
            
            heroViewModel = ToolPageContentStackViewModel(
                node: heroNode,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil
            )
        }
        else {
            heroViewModel = nil
        }
        
        // call to action
        callToActionViewModel = ToolPageCallToActionViewModel(
            pageNode: pageNode,
            toolPageColors: toolPageColors,
            fontService: fontService
        )
        
        // cards
        hidesCards = pageNode.cardsNode?.cards.isEmpty ?? true
        
        super.init()
        
        let visibleCards: [CardNode] = (pageNode.cardsNode?.cards ?? []).filter({$0.hidden != "true"})
        
        for cardIndex in 0 ..< visibleCards.count {
            
            let cardNode: CardNode = visibleCards[cardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: cardNode,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                mobileContentAnalytics: mobileContentAnalytics,
                mobileContentEvents: mobileContentEvents,
                fontService: fontService,
                localizationServices: localizationServices,
                cardPosition: cardIndex,
                totalCards: visibleCards.count,
                toolPageColors: toolPageColors
            )
            
            cardsViewModels.append(cardViewModel)
        }
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    func handleCallToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped()
    }
}

// MARK: - ToolPageCardViewModelDelegate

extension ToolPageViewModel: ToolPageCardViewModelDelegate {
    
    private func gotoPreviousCardFromCard(cardPosition: Int) {
        
        let previousCard: Int = cardPosition - 1
        
        if previousCard >= 0 {
            currentCard.accept(value: previousCard)
        }
        else {
            currentCard.accept(value: nil)
        }
    }
    
    func headerTappedFromCard(cardPosition: Int) {
                
        let isShowingCard: Bool = cardPosition == currentCard.value
        
        if !isShowingCard {
            currentCard.accept(value: cardPosition)
        }
        else {
            
            gotoPreviousCardFromCard(cardPosition: cardPosition)
        }
    }
    
    func previousTappedFromCard(cardPosition: Int) {
        
        gotoPreviousCardFromCard(cardPosition: cardPosition)
    }
    
    func nextTappedFromCard(cardPosition: Int) {
                
        let nextCard: Int = cardPosition + 1
        
        if nextCard <= cardsViewModels.count - 1 {
            currentCard.accept(value: nextCard)
        }
        else {
            delegate?.toolPageNextPageTapped()
        }
    }
    
    func cardSwipedUpFromCard(cardPosition: Int) {
        
        let isShowingCard: Bool = currentCard.value == cardPosition
        
        if isShowingCard {
            
            let nextCard: Int = cardPosition + 1
            
            if nextCard <= cardsViewModels.count - 1 {
                currentCard.accept(value: nextCard)
            }
        }
        else {
            currentCard.accept(value: cardPosition)
        }
    }
    
    func cardSwipedDownFromCard(cardPosition: Int) {
        
        let isShowingCard: Bool = currentCard.value == cardPosition
        
        if isShowingCard {
            gotoPreviousCardFromCard(cardPosition: cardPosition)
        }
    }
}
