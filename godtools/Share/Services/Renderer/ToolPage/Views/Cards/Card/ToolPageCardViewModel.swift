//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardViewModelDelegate: class {
    
    func headerTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func previousTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func nextTappedFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func cardSwipedUpFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func cardSwipedDownFromCard(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func presentCardListener(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
    func dismissCardListener(cardViewModel: ToolPageCardViewModel, cardPosition: Int)
}

class ToolPageCardViewModel: NSObject, ToolPageCardViewModelType {
    
    private let cardNode: CardNode
    private let mobileContentEvents: MobileContentEvents
    private let fontService: FontService
    private let localizationServices: LocalizationServices
    private let cardPosition: Int
    private let totalCards: Int
    private let toolPageColors: ToolPageColorsViewModel
    
    private weak var delegate: ToolPageCardViewModelDelegate?
    
    let contentStackViewModel: ToolPageContentStackViewModel
    let isHiddenCard: Bool
    let hidesCardNavigation: Bool
    
    required init(delegate: ToolPageCardViewModelDelegate, cardNode: CardNode, manifest: MobileContentXmlManifest, language: LanguageModel, translationsFileCache: TranslationsFileCache, mobileContentNodeParser: MobileContentXmlNodeParser, mobileContentAnalytics: MobileContentAnalytics, mobileContentEvents: MobileContentEvents, fontService: FontService, followUpsService: FollowUpsService, localizationServices: LocalizationServices, cardPosition: Int, totalCards: Int, toolPageColors: ToolPageColorsViewModel) {
        
        let isHiddenCard: Bool = cardNode.hidden == "true"
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.mobileContentEvents = mobileContentEvents
        self.fontService = fontService
        self.localizationServices = localizationServices
        self.cardPosition = cardPosition
        self.totalCards = totalCards
        self.toolPageColors = toolPageColors
        
        contentStackViewModel = ToolPageContentStackViewModel(
            node: cardNode,
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
            defaultTextNodeTextColor: toolPageColors.cardTextColor,
            defaultButtonBorderColor: nil,
            rootContentStack: nil
        )
        
        self.isHiddenCard = isHiddenCard
        hidesCardNavigation = isHiddenCard
        
        super.init()
        
        addListeners()
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        removeListeners()
    }
    
    private func addListeners() {
        
        mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
            guard let viewModel = self else {
                return
            }
            if viewModel.cardNode.listeners.contains(buttonEvent.event) {
                self?.delegate?.presentCardListener(cardViewModel: viewModel, cardPosition: viewModel.cardPosition)
            }
            else if viewModel.cardNode.dismissListeners.contains(buttonEvent.event) {
                self?.delegate?.dismissCardListener(cardViewModel: viewModel, cardPosition: viewModel.cardPosition)
            }
        }
    }
    
    private func removeListeners() {
        
        mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
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
        delegate?.headerTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func previousTapped() {
        delegate?.previousTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func nextTapped() {
        delegate?.nextTappedFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func didSwipeCardUp() {
        delegate?.cardSwipedUpFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
    
    func didSwipeCardDown() {
        delegate?.cardSwipedDownFromCard(cardViewModel: self, cardPosition: cardPosition)
    }
}
