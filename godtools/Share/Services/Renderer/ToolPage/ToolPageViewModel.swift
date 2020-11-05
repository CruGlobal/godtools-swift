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

class ToolPageViewModel: ToolPageViewModelType {
        
    private let pageNode: PageNode
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let localizationServices: LocalizationServices
    private let fontService: FontService
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
    
    required init(delegate: ToolPageViewModelDelegate, pageNode: PageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices, fontService: FontService, hidesBackgroundImage: Bool) {
                
        self.delegate = delegate
        self.pageNode = pageNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.localizationServices = localizationServices
        self.fontService = fontService
        self.toolPageColors = ToolPageColorsViewModel(pageNode: pageNode, manifest: manifest)
        self.hidesBackgroundImage = hidesBackgroundImage
        
        // background image
        if !hidesBackgroundImage, let backgroundSrc = manifest.resources[pageNode.backgroundImage ?? ""]?.src {
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
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                fontService: fontService
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
                itemSpacing: 20,
                scrollIsEnabled: true,
                toolPageColors: toolPageColors,
                defaultTextNodeTextColor: nil,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                fontService: fontService
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
        
        let cards: [CardNode] = pageNode.cardsNode?.cards ?? []
        
        for cardIndex in 0 ..< cards.count {
            
            let cardNode: CardNode = cards[cardIndex]
            
            let cardViewModel = ToolPageCardViewModel(
                delegate: self,
                cardNode: cardNode,
                cardPosition: cardIndex,
                totalCards: cards.count,
                toolPageColors: toolPageColors,
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                localizationServices: localizationServices,
                fontService: fontService
            )
            
            cardsViewModels.append(cardViewModel)
        }
    }
    
    func handleCallToActionNextButtonTapped() {
        delegate?.toolPageNextPageTapped()
    }
}

// MARK: - ToolPageCardViewModelDelegate

extension ToolPageViewModel: ToolPageCardViewModelDelegate {
    
    func headerTappedFromCard(cardPosition: Int) {
        
        currentCard.accept(value: cardPosition)
    }
    
    func previousTappedFromCard(cardPosition: Int) {
        
        let previousCard: Int = cardPosition - 1
        
        currentCard.accept(value: previousCard)
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
}
