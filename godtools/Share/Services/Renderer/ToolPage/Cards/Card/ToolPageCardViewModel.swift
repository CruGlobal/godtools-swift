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
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let cardPosition: Int
    private let totalCards: Int
    private let toolPageColors: ToolPageColorsViewModel
    
    private weak var delegate: ToolPageCardViewModelDelegate?
    
    let contentStackViewModel: ToolPageContentStackViewModel
    
    required init(delegate: ToolPageCardViewModelDelegate, cardNode: CardNode, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, mobileContentEvents: MobileContentEvents, fontService: FontService, localizationServices: LocalizationServices, cardPosition: Int, totalCards: Int, toolPageColors: ToolPageColorsViewModel) {
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardPosition = cardPosition
        self.totalCards = totalCards
        self.toolPageColors = toolPageColors
        
        contentStackViewModel = ToolPageContentStackViewModel(
            node: cardNode,
            manifest: manifest,
            translationsFileCache: translationsFileCache,
            mobileContentEvents: mobileContentEvents,
            fontService: fontService,
            itemSpacing: 20,
            scrollIsEnabled: true,
            toolPageColors: toolPageColors,
            defaultTextNodeTextColor: toolPageColors.cardTextColor
        )
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
