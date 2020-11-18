//
//  ToolPageCardViewModel.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardViewModel: NSObject, ToolPageCardViewModelType {
    
    private let cardNode: CardNode
    private let diContainer: ToolPageDiContainer
    private let cardPosition: Int
    private let visibleCardPosition: Int?
    private let hiddenCardPosition: Int?
    private let numberOfCards: Int
    private let toolPageColors: ToolPageColorsViewModel
    
    private weak var delegate: ToolPageCardViewModelTypeDelegate?
    
    let contentStackViewModel: ToolPageContentStackViewModel
    let isHiddenCard: Bool
    let hidesCardNavigation: Bool
    
    required init(delegate: ToolPageCardViewModelTypeDelegate, cardNode: CardNode, diContainer: ToolPageDiContainer, cardPosition: Int, visibleCardPosition: Int?, hiddenCardPosition: Int?, numberOfCards: Int, toolPageColors: ToolPageColorsViewModel) {
        
        let isHiddenCard: Bool = cardNode.hidden == "true"
        
        self.delegate = delegate
        self.cardNode = cardNode
        self.diContainer = diContainer
        self.cardPosition = cardPosition
        self.visibleCardPosition = visibleCardPosition
        self.hiddenCardPosition = hiddenCardPosition
        self.numberOfCards = numberOfCards
        self.toolPageColors = toolPageColors
        
        contentStackViewModel = ToolPageContentStackViewModel(
            node: cardNode,
            diContainer: diContainer,
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
        
        diContainer.mobileContentEvents.eventButtonTappedSignal.addObserver(self) { [weak self] (buttonEvent: ButtonEvent) in
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
        
        diContainer.mobileContentEvents.eventButtonTappedSignal.removeObserver(self)
    }
    
    var title: String? {
        let title: String? = cardNode.labelNode?.textNode?.text
        return title
    }
    
    var titleColor: UIColor {
        return cardNode.labelNode?.textNode?.getTextColor()?.color ?? toolPageColors.primaryColor
    }
    
    var titleFont: UIFont {
        return diContainer.fontService.getFont(size: 19, weight: .regular)
    }
    
    var cardPositionLabel: String? {
        let cardPosition: Int = visibleCardPosition ?? 0
        return String(cardPosition+1) + "/" + String(numberOfCards)
    }
    
    var cardPositionLabelTextColor: UIColor {
        return .gray
    }
    
    var cardPositionLabelFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
    }
    
    var previousButtonTitle: String? {
        return diContainer.localizationServices.stringForMainBundle(key: "card_status1")
    }
    
    var previousButtonTitleColor: UIColor {
        return .gray
    }
    
    var previousButtonTitleFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
    }
    
    var nextButtonTitle: String? {
        return diContainer.localizationServices.stringForMainBundle(key: "card_status2")
    }
    
    var nextButtonTitleColor: UIColor {
        return .gray
    }
    
    var nextButtonTitleFont: UIFont {
        return diContainer.fontService.getFont(size: 18, weight: .regular)
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
