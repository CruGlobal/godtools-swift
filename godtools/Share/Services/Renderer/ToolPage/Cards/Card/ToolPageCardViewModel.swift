//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardViewModelDelegate: class {
    
    func headerTappedFromCard(cardPosition: Int)
    func previousTappedFromCard(cardPosition: Int)
    func nextTappedFromCard(cardPosition: Int)
    func cardSwipedUpFromCard(cardPosition: Int)
    func cardSwipedDownFromCard(cardPosition: Int)
}

class ToolPageCardViewModel: ToolPageCardViewModelType {
    
    private let cardNode: CardNode
    private let cardPosition: Int
    private let totalCards: Int
    private let toolPageColors: ToolPageColorsViewModel
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let toolPageViewFactory: ToolPageViewFactory
    private let localizationServices: LocalizationServices
    private let fontService: FontService
    
    private weak var delegate: ToolPageCardViewModelDelegate?
    
    let contentStackViewModel: ToolPageContentStackViewModel
    
    required init(delegate: ToolPageCardViewModelDelegate, cardNode: CardNode, cardPosition: Int, totalCards: Int, toolPageColors: ToolPageColorsViewModel, manifest: MobileContentXmlManifest, toolPageViewFactory: ToolPageViewFactory, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices, fontService: FontService) {
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.cardPosition = cardPosition
        self.totalCards = totalCards
        self.toolPageColors = toolPageColors
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.toolPageViewFactory = toolPageViewFactory
        self.localizationServices = localizationServices
        self.fontService = fontService
        
        contentStackViewModel = ToolPageContentStackViewModel(
            node: cardNode,
            itemSpacing: 20,
            scrollIsEnabled: true,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: toolPageColors.cardTextColor,
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            toolPageViewFactory: toolPageViewFactory,
            fontService: fontService
        )
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
    
    var cardPositionLabel: String? {
        return String(cardPosition+1) + "/" + String(totalCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return localizationServices.stringForMainBundle(key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForMainBundle(key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return fontService.getFont(size: 18, weight: .regular)
    }
    
    func headerTapped() {
        delegate?.headerTappedFromCard(cardPosition: cardPosition)
    }
    
    func previousTapped() {
        delegate?.previousTappedFromCard(cardPosition: cardPosition)
    }
    
    func nextTapped() {
        delegate?.nextTappedFromCard(cardPosition: cardPosition)
    }
    
    func didSwipeCardUp() {
        delegate?.cardSwipedUpFromCard(cardPosition: cardPosition)
    }
    
    func didSwipeCardDown() {
        delegate?.cardSwipedDownFromCard(cardPosition: cardPosition)
    }
}
