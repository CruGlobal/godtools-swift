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
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let localizationServices: LocalizationServices
    private let primaryColor: UIColor
    private let primaryTextColor: UIColor
        
    private(set) var cardsViewModels: [ToolPageCardViewModelType] = Array()
    
    let backgroundImage: UIImage?
    let hidesBackgroundImage: Bool
    let contentStackViewModel: ToolPageContentStackViewModel?
    let headerViewModel: ToolPageHeaderViewModel
    let heroViewModel: ToolPageContentStackViewModel?
    let hidesCards: Bool
    let currentCard: ObservableValue<Int?> = ObservableValue(value: nil)
    let callToActionViewModel: ToolPageCallToActionViewModel
    
    required init(pageNode: PageNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices, hidesBackgroundImage: Bool) {
        
        let primaryColor: UIColor = pageNode.getPrimaryColor()?.color ?? manifest.attributes.getPrimaryColor().color
        let primaryTextColor: UIColor = pageNode.getPrimaryTextColor()?.color ?? manifest.attributes.getPrimaryTextColor().color
        
        self.pageNode = pageNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.localizationServices = localizationServices
        self.primaryColor = primaryColor
        self.primaryTextColor = primaryTextColor
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
                defaultPrimaryColor: primaryColor,
                defaultPrimaryTextColor: primaryTextColor,
                manifest: manifest,
                translationsFileCache: translationsFileCache
            )
        }
        else {
            contentStackViewModel = nil
        }
        
        // header
        headerViewModel = ToolPageHeaderViewModel(
            pageNode: pageNode,
            backgroundColor: primaryColor,
            primaryTextColor: primaryTextColor
        )
        
        // hero
        if let heroNode = pageNode.heroNode {
            
            heroViewModel = ToolPageContentStackViewModel(
                node: heroNode,
                itemSpacing: 20,
                scrollIsEnabled: true,
                defaultPrimaryColor: primaryColor,
                defaultPrimaryTextColor: primaryTextColor,
                manifest: manifest,
                translationsFileCache: translationsFileCache
            )
        }
        else {
            heroViewModel = nil
        }
        
        // call to action
        callToActionViewModel = ToolPageCallToActionViewModel(
            pageNode: pageNode,
            primaryColor: primaryColor,
            primaryTextColor: primaryTextColor
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
                manifest: manifest,
                translationsFileCache: translationsFileCache,
                localizationServices: localizationServices
            )
            
            cardsViewModels.append(cardViewModel)
        }
    }
}

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
        
        currentCard.accept(value: nextCard)
    }
}
