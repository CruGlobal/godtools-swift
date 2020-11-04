//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import Foundation

protocol ToolPageCardViewModelDelegate: class {
    
    func headerTappedFromCard(cardPosition: Int)
    func previousTappedFromCard(cardPosition: Int)
    func nextTappedFromCard(cardPosition: Int)
}

class ToolPageCardViewModel: ToolPageCardViewModelType {
    
    private let cardNode: CardNode
    private let cardPosition: Int
    private let totalCards: Int
    private let manifest: MobileContentXmlManifest
    private let translationsFileCache: TranslationsFileCache
    private let localizationServices: LocalizationServices
    
    private weak var delegate: ToolPageCardViewModelDelegate?
    
    required init(delegate: ToolPageCardViewModelDelegate, cardNode: CardNode, cardPosition: Int, totalCards: Int, manifest: MobileContentXmlManifest, translationsFileCache: TranslationsFileCache, localizationServices: LocalizationServices) {
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.cardPosition = cardPosition
        self.totalCards = totalCards
        self.manifest = manifest
        self.translationsFileCache = translationsFileCache
        self.localizationServices = localizationServices
    }
    
    var title: String? {
        let title: String? = cardNode.labelNode?.textNode?.text
        return title
    }
    
    var cardPositionLabel: String? {
        return String(cardPosition) + "/" + String(totalCards)
    }
    
    var previousButtonTitle: String? {
        return localizationServices.stringForMainBundle(key: "card_status1")
    }
    
    var nextButtonTitle: String? {
        return localizationServices.stringForMainBundle(key: "card_status2")
    }
    
    func contentStackWillAppear() -> ToolPageContentStackViewModel {
        
        return ToolPageContentStackViewModel(
            node: cardNode,
            itemSpacing: 20,
            scrollIsEnabled: true,
            defaultPrimaryColor: .red,
            defaultPrimaryTextColor: .magenta,
            manifest: manifest,
            translationsFileCache: translationsFileCache
        )
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
}
