//
//  ToolPageCardsView.swift
//  godtools
//
//  Created by Levi Eggert on 12/8/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardsViewDelegate: class {
    
    func toolPageCardsStateDidChange(toolPageCards: ToolPageCardsView, viewModel: ToolPageViewModelType, cardsState: ToolPageCardsState, animated: Bool)
}

class ToolPageCardsView: NSObject, ReusableView {
    
    private let keyboardObserver: KeyboardObserverType = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var viewModel: ToolPageViewModelType?
    private var safeArea: UIEdgeInsets = .zero
    private var cards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var cardHeightConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var cardBounceAnimation: ToolPageCardBounceAnimation?
    
    private weak var parentView: UIView?
    private weak var callToActionView: UIView?
    private weak var delegate: ToolPageCardsViewDelegate?
    
    required override init() {
        
        super.init()
        
        keyboardObserver.startObservingKeyboardChanges()
        
        // keyboard
        keyboardObserver.keyboardStateDidChangeSignal.addObserver(self) { [weak self] (keyboardStateChange: KeyboardStateChange) in
            self?.handleKeyboardStateChange(keyboardStateChange: keyboardStateChange)
        }
    }
    
    deinit {
        
        keyboardObserver.stopObservingKeyboardChanges()
        keyboardObserver.keyboardStateDidChangeSignal.removeObserver(self)
        keyboardObserver.keyboardHeightDidChangeSignal.removeObserver(self)
    }
    
    func resetView() {
           
        currentCardState = .initialized
        resetCards()
        self.viewModel = nil
    }
    
    private func resetCards() {
        
        guard !cards.isEmpty else {
            return
        }
        
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        
        for index in 0 ..< cards.count {
            
            let cardView: ToolPageCardView = cards[index]
            let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[index]
            cardView.resetView()
            cardView.isHidden = true
            cardTopConstraint.constant = screenHeight
        }
        parentView?.layoutIfNeeded()
    }
    
    func configure(parentView: UIView, viewModel: ToolPageViewModelType, safeArea: UIEdgeInsets, callToActionView: UIView, delegate: ToolPageCardsViewDelegate) {
        
        self.parentView = parentView
        self.viewModel = viewModel
        self.safeArea = safeArea
        self.callToActionView = callToActionView
        self.delegate = delegate
        
        guard viewModel.numberOfCards > 0 else {
            return
        }
        
        addCardsAndCardsConstraints(
            parentView: parentView,
            cardsViewModels: viewModel.cardsViewModels
        )
                
        setCardsState(viewModel: viewModel, cardsState: .starting, animated: false)
        
        viewModel.currentCard.addObserver(self) { [weak self] (cardPositionAnimatable: AnimatableValue<Int?>) in
            self?.setCardsState(viewModel: viewModel, cardsState: .showingCard(showingCardAtPosition: cardPositionAnimatable.value), animated: cardPositionAnimatable.animated)
        }
        
        viewModel.hidesCardJump.addObserver(self) { [weak self] (hidesCardJump: Bool) in
           
            guard let cardsView = self else {
                return
            }
            
            if hidesCardJump {
                cardsView.cardBounceAnimation?.stopAnimation(forceStop: true)
            }
            else if !hidesCardJump, let firstCard = self?.cards.first, let firstContraint = self?.cardTopConstraints.first {
                
                cardsView.cardBounceAnimation = ToolPageCardBounceAnimation(
                    card: firstCard,
                    cardTopConstraint: firstContraint,
                    cardStartingTopConstant: cardsView.getCardTopConstant(state: .starting(cardPosition: 0)),
                    layoutView: parentView,
                    delegate: cardsView
                )
                cardsView.cardBounceAnimation?.startAnimation()
            }
        }
    }
    
    var numberOfCards: Int {
        return viewModel?.numberOfCards ?? 0
    }
    
    func getFirstCard() -> ToolPageCardView? {
        return cards.first
    }
    
    private var callToActionFrameHeight: CGFloat {
        return callToActionView?.frame.size.height ?? 0
    }
}

// MARK: - ToolPageCardBounceAnimationDelegate

extension ToolPageCardsView: ToolPageCardBounceAnimationDelegate {
    func toolPageCardBounceAnimationDidFinish(cardBounceAnimation: ToolPageCardBounceAnimation, forceStopped: Bool) {
        viewModel?.cardBounceAnimationFinished()
    }
}

// MARK: - Keyboard

extension ToolPageCardsView {
    
    func handleKeyboardStateChange(keyboardStateChange: KeyboardStateChange) {
        
        guard let viewModel = self.viewModel else {
            return
        }
        
        guard let currentCardPosition = viewModel.currentCard.value.value else {
            return
        }
        
        guard currentCardPosition >= 0 && currentCardPosition < numberOfCards else {
            return
        }
        
        switch keyboardStateChange.keyboardState {

        case .willShow:
            setCardsState(viewModel: viewModel, cardsState: .showingKeyboard(showingCardAtPosition: currentCardPosition), animated: true)
        case .willHide:
            setCardsState(viewModel: viewModel, cardsState: .showingCard(showingCardAtPosition: currentCardPosition), animated: true)
        case .didShow:
            break
        case .didHide:
            break
        }
    }
    
    func handleKeyboardHeightChanged(keyboardHeight: Double) {
        
    }
}

// MARK: - Cards

extension ToolPageCardsView {
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var cardsContainerFrameRelativeToScreen: CGRect {
        let screenSize: CGSize = UIScreen.main.bounds.size
        let height: CGFloat = screenSize.height - safeArea.top - safeArea.bottom
        return CGRect(x: 0, y: safeArea.top, width: screenSize.width, height: height)
    }
    
    private var cardCollapsedVisibilityPercentage: CGFloat {
        return 0.4
    }
    
    private var cardsTopRelativeToCardsContainerFrameBottom: CGFloat {
        return cardsContainerFrameRelativeToScreen.origin.y + cardsContainerFrameRelativeToScreen.size.height
    }
    
    private var cardsContainerHeight: CGFloat {
        return cardsContainerFrameRelativeToScreen.size.height
    }
    
    private var cardHeight: CGFloat {
                
        guard let cardView = cards.first else {
            assertionFailure("Cards should be initialized before cardHeight is accessed.")
            return cardsContainerHeight - callToActionFrameHeight - cardInsets.top - cardInsets.bottom
        }
                
        let numberOfVisibleCards: CGFloat = CGFloat(viewModel?.numberOfVisibleCards ?? 0)
        let cardTitleHeight: CGFloat = cardView.cardHeaderHeight
        let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
        let collapsedCardsHeight: CGFloat = (cardTopVisibilityHeight * (numberOfVisibleCards - 1))
                
        let maxFooterAreaHeight: CGFloat = (collapsedCardsHeight > callToActionFrameHeight) ? collapsedCardsHeight : callToActionFrameHeight
        
        let cardHeight: CGFloat = cardsContainerHeight - cardInsets.top - cardInsets.bottom - maxFooterAreaHeight
        
        return cardHeight
    }
    
    private func getCardTopConstraint(cardPosition: Int) -> NSLayoutConstraint? {
        if cardPosition >= 0 && cardPosition < cardTopConstraints.count {
            return cardTopConstraints[cardPosition]
        }
        return nil
    }
    
    private func getCardTopConstant(state: ToolPageCardTopConstantState) -> CGFloat {
        
        guard let cardView = cards.first else {
            return UIScreen.main.bounds.size.height
        }
        
        let numberOfVisibleCards: CGFloat = CGFloat(viewModel?.numberOfVisibleCards ?? 0)
        let cardTitleHeight: CGFloat = cardView.cardHeaderHeight
        
        switch state {
            
        case .starting(let cardPosition):
            return cardsTopRelativeToCardsContainerFrameBottom - (cardTitleHeight * (numberOfVisibleCards - CGFloat(cardPosition)))
        
        case .showing:
            return cardsContainerFrameRelativeToScreen.origin.y + cardInsets.top
        
        case .showingKeyboard:
            return cardsContainerFrameRelativeToScreen.origin.y + cardInsets.top
            
        case .collapsed(let cardPosition):
            let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
            return cardsTopRelativeToCardsContainerFrameBottom - (cardTopVisibilityHeight * (numberOfVisibleCards - CGFloat(cardPosition)))
        
        case .hidden:
            return UIScreen.main.bounds.size.height
        }
    }
    
    private func setCardsState(viewModel: ToolPageViewModelType, cardsState: ToolPageCardsState, animated: Bool) {
        
        delegate?.toolPageCardsStateDidChange(
            toolPageCards: self,
            viewModel: viewModel,
            cardsState: cardsState,
            animated: animated
        )
        
        switch cardsState {
            
        case .starting:
                        
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardViewModel: ToolPageCardViewModelType = viewModel.cardsViewModels[cardPosition]
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if !cardViewModel.isHiddenCard {
                    cardTopConstraint.constant = getCardTopConstant(state: .starting(cardPosition: visibleCardPosition))
                    visibleCardPosition += 1
                }
                else {
                    cardTopConstraint.constant = getCardTopConstant(state: .hidden)
                }
            }
            
        case .showingCard(let showingCardAtPosition):
            
            // nothing to show if the card is nil and we are at the cards starting positions state
            if showingCardAtPosition == nil && currentCardState == .starting {
                return
            }
            
            guard let showCardAtPosition = showingCardAtPosition else {
                setCardsState(viewModel: viewModel, cardsState: .collapseAllCards, animated: animated)
                return
            }
            
            guard showCardAtPosition >= 0 && showCardAtPosition < numberOfCards else {
                return
            }
                        
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardViewModel: ToolPageCardViewModelType = viewModel.cardsViewModels[cardPosition]
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                let shouldShowCard: Bool = cardPosition <= showCardAtPosition
                
                if shouldShowCard {
                    cardTopConstraint.constant = getCardTopConstant(state: .showing)
                }
                else {
                    if !cardViewModel.isHiddenCard {
                        cardTopConstraint.constant = getCardTopConstant(state: .collapsed(cardPosition: visibleCardPosition))
                    }
                    else {
                        cardTopConstraint.constant = getCardTopConstant(state: .hidden)
                    }
                }
                
                if !cardViewModel.isHiddenCard {
                    visibleCardPosition += 1
                }
            }
            
        case .showingKeyboard(let showingCardAtPosition):
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if cardPosition <= showingCardAtPosition {
                    cardTopConstraint.constant = getCardTopConstant(state: .showingKeyboard)
                }
            }
                        
        case .collapseAllCards:
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardViewModel: ToolPageCardViewModelType = viewModel.cardsViewModels[cardPosition]
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if !cardViewModel.isHiddenCard {
                    cardTopConstraint.constant = getCardTopConstant(state: .collapsed(cardPosition: visibleCardPosition))
                    visibleCardPosition += 1
                }
                else {
                    cardTopConstraint.constant = getCardTopConstant(state: .hidden)
                }
            }
            
        case .initialized:
            break
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.parentView?.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(viewModel: viewModel, cardsState: cardsState, animated: animated)
            })
        }
        else {
            parentView?.layoutIfNeeded()
            handleCompletedSetCardState(viewModel: viewModel, cardsState: cardsState, animated: animated)
        }
        
        currentCardState = cardsState
    }
    
    private func handleCompletedSetCardState(viewModel: ToolPageViewModelType, cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
        
        case .starting:
            break
            
        case .showingCard(let showingCardAtPosition):
            break
            
        case .showingKeyboard:
            break
                        
        case .collapseAllCards:
            setCardsState(viewModel: viewModel, cardsState: .starting, animated: animated)
            
        case .initialized:
            break
        }
    }
    
    private func addCardsAndCardsConstraints(parentView: UIView, cardsViewModels: [ToolPageCardViewModelType]) {
        
        for index in 0 ..< cardsViewModels.count {
            
            let cardViewModel: ToolPageCardViewModelType = cardsViewModels[index]
            
            if index >= 0 && index < cards.count {
                
                let cardView: ToolPageCardView = cards[index]
                
                cardView.configure(viewModel: cardViewModel)
                cardView.isHidden = false
                cardHeightConstraints[index].constant = cardHeight
            }
            else {
                
                instatiateAndAddNewCard(parentView: parentView, cardViewModel: cardViewModel)
            }
        }
        
        parentView.layoutIfNeeded()
    }
    
    private func instatiateAndAddNewCard(parentView: UIView, cardViewModel: ToolPageCardViewModelType) {
        
        let cardView: ToolPageCardView = ToolPageCardView()
        
        cardView.configure(viewModel: cardViewModel)
        
        cards.append(cardView)
        
        parentView.addSubview(cardView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .top,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .top,
            multiplier: 1,
            constant: cardInsets.top
        )
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .leading,
            multiplier: 1,
            constant: cardInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: parentView,
            attribute: .trailing,
            multiplier: 1,
            constant: cardInsets.right * -1
        )
        
        parentView.addConstraint(top)
        parentView.addConstraint(leading)
        parentView.addConstraint(trailing)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: cardHeight
        )
        
        cardView.addConstraint(heightConstraint)
        
        cardTopConstraints.append(top)
        cardHeightConstraints.append(heightConstraint)
    }
}
