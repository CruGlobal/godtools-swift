//
//  ToolPageCardsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol ToolPageCardsViewDelegate: AnyObject {
    
    func toolPageCardsDidChangeCardState(cardsView: ToolPageCardsView, cardsState: ToolPageCardsState, animated: Bool)
    func toolPageCardsDidChangeCardPosition(cardsView: ToolPageCardsView, cardPosition: Int?, animated: Bool)
}

class ToolPageCardsView: MobileContentView {
    
    private let viewModel: ToolPageCardsViewModelType
    private let safeArea: UIEdgeInsets
    private let keyboardObserver: KeyboardObserverType = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var cardBounceAnimation: ToolPageCardBounceAnimation?
    private var allCards: [ToolPageCardView] = Array()
    private var renderedCards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var cardParentContentInsets: UIEdgeInsets = .zero
    private var currentCardPosition: Int?
    private var isObservingCardJump: Bool = false
    
    private weak var renderedCardsParentView: UIView?
    private weak var delegate: ToolPageCardsViewDelegate?
    
    required init(viewModel: ToolPageCardsViewModelType, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        keyboardObserver.startObservingKeyboardChanges()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        keyboardObserver.stopObservingKeyboardChanges()
        keyboardObserver.keyboardStateDidChangeSignal.removeObserver(self)
        keyboardObserver.keyboardHeightDidChangeSignal.removeObserver(self)
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        keyboardObserver.keyboardStateDidChangeSignal.addObserver(self) { [weak self] (keyboardStateChange: KeyboardStateChange) in
            self?.handleKeyboardStateChange(keyboardStateChange: keyboardStateChange)
        }
    }
    
    private func addCardJumpObserving() {
        
        guard !isObservingCardJump else {
            return
        }
        
        isObservingCardJump = true
        
        viewModel.hidesCardJump.addObserver(self) { [weak self] (hidesCardJump: Bool) in
            
            guard let cardsView = self else {
                return
            }
            
            let firstCard: ToolPageCardView? = cardsView.renderedCards.first
            let firstCardTopConstraint: NSLayoutConstraint? = cardsView.cardTopConstraints.first
            let cardsParent: UIView? = cardsView.renderedCardsParentView
            
            if hidesCardJump, let cardBounceAnimation = self?.cardBounceAnimation {
                cardBounceAnimation.stopAnimation(forceStop: true)
            }
            else if !hidesCardJump, let firstCard = firstCard, let firstCardTopConstraint = firstCardTopConstraint, let cardsParent = cardsParent {
                
                let cardBounceAnimation = ToolPageCardBounceAnimation(
                    card: firstCard,
                    cardTopConstraint: firstCardTopConstraint,
                    cardStartingTopConstant: cardsView.getCardTopConstant(state: .starting(cardPosition: 0)),
                    layoutView: cardsParent,
                    delegate: cardsView
                )
                cardBounceAnimation.startAnimation()
                self?.cardBounceAnimation = cardBounceAnimation
            }
        }
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let cardView = childView as? ToolPageCardView {
            allCards.append(cardView)
        }
    }
    
    override func didReceiveEvent(eventId: EventId, eventIdsGroup: [EventId]) -> ProcessedEventResult? {
                
        for cardView in allCards {
            
            if cardView.containsDismissListener(eventId: eventId) {
                dismissCard(cardView: cardView)
            }
            else if cardView.containsListener(eventId: eventId) {
                presentCard(cardView: cardView)
            }
        }
        
        return nil
    }
    
    // MARK: -
    
    func setCardsViewDelegate(delegate: ToolPageCardsViewDelegate) {
        self.delegate = delegate
    }
    
    private func dismissCard(cardView: ToolPageCardView) {
        
        guard let cardPosition = getRenderedCardPosition(cardView: cardView) else {
            return
        }
            
        gotoPreviousCardFromCardPosition(cardPosition: cardPosition, animated: true)
    }
    
    private func presentCard(cardView: ToolPageCardView) {
          
        addCardToRenderedCards(cardView: cardView)
        
        guard let cardPosition = getRenderedCardPosition(cardView: cardView) else {
            return
        }
        
        setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: cardPosition), animated: true)
    }
}

// MARK: - Keyboard

extension ToolPageCardsView {
    
    func handleKeyboardStateChange(keyboardStateChange: KeyboardStateChange) {
        
        guard let currentCardPosition = self.currentCardPosition else {
            return
        }
        
        switch keyboardStateChange.keyboardState {

        case .willShow:
            setRenderedCardsState(cardsState: .showingKeyboard(showingCardAtPosition: currentCardPosition), animated: true)
        case .willHide:
            setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: currentCardPosition), animated: true)
        case .didShow:
            break
        case .didHide:
            break
        }
    }
    
    func handleKeyboardHeightChanged(keyboardHeight: Double) {
        
    }
}

// MARK: - ToolPageCardBounceAnimationDelegate

extension ToolPageCardsView: ToolPageCardBounceAnimationDelegate {
    func toolPageCardBounceAnimationDidFinish(cardBounceAnimation: ToolPageCardBounceAnimation, forceStopped: Bool) {
        viewModel.cardBounceAnimationFinished()
    }
}

// MARK: - ToolPageCardViewDelegate

extension ToolPageCardsView: ToolPageCardViewDelegate {
    
    func toolPageCardHeaderTapped(cardView: ToolPageCardView) {
        
        guard let cardPosition = getRenderedCardPosition(cardView: cardView) else {
            return
        }
        
        viewModel.cardHeaderTapped()
        
        if cardPosition != currentCardPosition {
            setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: cardPosition), animated: true)
        }
        else {
            setRenderedCardsState(cardsState: .collapseAllCards, animated: true)
        }
    }
    
    func toolPageCardPreviousTapped(cardView: ToolPageCardView) {
        
        gotoPreviousCard(animated: true)
    }
    
    func toolPageCardNextTapped(cardView: ToolPageCardView) {
        
        gotoNextCard(animated: true)
    }
    
    func toolPageCardDidSwipeCardUp(cardView: ToolPageCardView) {
        
        viewModel.cardSwipedUp()
        
        gotoNextCard(animated: true)
    }
    
    func toolPageCardDidSwipeCardDown(cardView: ToolPageCardView) {
                
        gotoPreviousCard(animated: true)
    }
    
    private func gotoPreviousCard(animated: Bool) {
        
        guard let cardPosition = currentCardPosition else {
            return
        }
        
        gotoPreviousCardFromCardPosition(cardPosition: cardPosition, animated: animated)
    }
    
    private func gotoPreviousCardFromCardPosition(cardPosition: Int, animated: Bool) {
        
        let previousCard: Int = cardPosition - 1
        
        if previousCard >= 0 {
            setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: previousCard), animated: animated)
        }
        else {
            setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: nil), animated: animated)
        }
    }
    
    private func gotoNextCard(animated: Bool) {
        
        guard let cardPosition = currentCardPosition else {
            return
        }
        
        let nextCard: Int = cardPosition + 1
        
        guard nextCard < renderedCards.count else {
            return
        }
        
        setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: nextCard), animated: animated)
    }
}

// MARK: - Rendering Cards

extension ToolPageCardsView {
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var showCardTopInset: CGFloat {
        return safeArea.top + cardParentContentInsets.top + cardInsets.top
    }
    
    private var showCardBottomInset: CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(allCards.filter({!$0.isHidden}).count)
        let cardHeaderHeight: CGFloat = ToolPageCardView.cardHeaderHeight
        let cardTopVisibilityHeight: CGFloat = floor(cardHeaderHeight * cardCollapsedVisibilityPercentage)
        let collapsedCardsHeight: CGFloat = (cardTopVisibilityHeight * (numberOfVisibleCardsFloatValue - 1))
        let availableBottomSpaces: [CGFloat] = [collapsedCardsHeight, cardParentContentInsets.bottom]
        let maxBottomSpace: CGFloat = availableBottomSpaces.max() ?? 0
        
        return safeArea.bottom + maxBottomSpace + cardInsets.bottom
    }
    
    private var cardCollapsedVisibilityPercentage: CGFloat {
        return 0.4
    }
    
    func renderCardsInParentView(renderedCardsParentView: UIView, cardInsets: UIEdgeInsets) {
        
        removeAllRenderedCards()
        
        self.renderedCardsParentView = renderedCardsParentView
        self.cardParentContentInsets = cardInsets
        
        for cardView in allCards {
            
            guard !cardView.isHiddenCard else {
                continue
            }
            
            addCardToRenderedCards(cardView: cardView)
        }
        
        setRenderedCardsState(cardsState: .starting, animated: false)
        
        addCardJumpObserving()
    }
    
    private func addCardToRenderedCards(cardView: ToolPageCardView) {
        
        guard let cardsParentView = renderedCardsParentView else {
            return
        }
        
        guard !renderedCards.contains(cardView) else {
            return
        }
        
        renderedCards.append(cardView)
        
        cardsParentView.addSubview(cardView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .top,
            relatedBy: .equal,
            toItem: cardsParentView,
            attribute: .top,
            multiplier: 1,
            constant: cardInsets.top
        )
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: cardsParentView,
            attribute: .leading,
            multiplier: 1,
            constant: cardInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: cardsParentView,
            attribute: .trailing,
            multiplier: 1,
            constant: cardInsets.right * -1
        )
        
        cardsParentView.addConstraint(top)
        cardsParentView.addConstraint(leading)
        cardsParentView.addConstraint(trailing)
               
        let cardHeight: CGFloat = getRenderedCardHeight()
        
        cardView.setHeightConstraint(height: cardHeight)
        
        top.constant = getCardTopConstant(state: .hidden)
                    
        cardTopConstraints.append(top)
        
        cardView.setDelegate(delegate: self)
        
        cardsParentView.layoutIfNeeded()
    }
    
    private func removeHiddenRenderedCards(animated: Bool, afterIndex: Int = -1) {
                
        for index in stride(from: renderedCards.count - 1, through: 0, by: -1) {
            
            guard renderedCards[index].isHiddenCard else {
                continue
            }
            
            guard index > afterIndex else {
                continue
            }
                
            removeHiddenCardFromRenderedCards(cardView: renderedCards[index], animated: animated)
        }
    }
    
    private func removeHiddenCardFromRenderedCards(cardView: ToolPageCardView, animated: Bool) {
        
        guard cardView.isHiddenCard && renderedCards.contains(cardView) else {
            return
        }
        
        if animated, let cardPosition = getRenderedCardPosition(cardView: cardView) {
            
            cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .hidden)
            
            removeRenderedCard(index: cardPosition, shouldRemoveFromView: false)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.renderedCardsParentView?.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                cardView.removeFromSuperview()
            })
        }
        else {
            
            removeRenderedCard(cardView: cardView, shouldRemoveFromView: true)
        }
    }
    
    private func removeAllRenderedCards() {
        
        for index in stride(from: renderedCards.count - 1, through: 0, by: -1) {
            
            removeRenderedCard(index: index, shouldRemoveFromView: true)
        }
    }
    
    private func removeRenderedCard(cardView: ToolPageCardView, shouldRemoveFromView: Bool) {
        
        guard let index = renderedCards.firstIndex(of: cardView) else {
            return
        }
        
        removeRenderedCard(index: index, shouldRemoveFromView: shouldRemoveFromView)
    }
    
    private func removeRenderedCard(index: Int, shouldRemoveFromView: Bool) {
        
        guard index >= 0 && index < renderedCards.count && index < cardTopConstraints.count else {
            return
        }
        
        if shouldRemoveFromView {
            renderedCards[index].removeFromSuperview()
        }
        
        renderedCards[index].setDelegate(delegate: nil)
        renderedCards.remove(at: index)
        cardTopConstraints.remove(at: index)
    }
    
    private func getRenderedCardPosition(cardView: ToolPageCardView) -> Int? {
        return renderedCards.firstIndex(of: cardView)
    }
    
    private func getRenderedCardView(cardPosition: Int) -> ToolPageCardView? {
        guard cardPosition >= 0 && cardPosition < renderedCards.count else {
            return nil
        }
        return renderedCards[cardPosition]
    }

    private func getRenderedCardHeight() -> CGFloat {
        
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        let topInset: CGFloat = showCardTopInset
        let bottomInset: CGFloat = showCardBottomInset
        
        return screenHeight - topInset - bottomInset
    }
    
    private func getCardTopConstant(state: ToolPageCardTopConstantState) -> CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(renderedCards.count)
        let cardHeaderHeight: CGFloat = ToolPageCardView.cardHeaderHeight
        
        switch state {
            
        case .starting(let cardPosition):
            return UIScreen.main.bounds.size.height - safeArea.bottom - (cardHeaderHeight * (numberOfVisibleCardsFloatValue - CGFloat(cardPosition)))
        
        case .showing:
            return showCardTopInset
        
        case .showingKeyboard:
            return showCardTopInset
            
        case .collapsed(let cardPosition):
            let cardTopVisibilityHeight: CGFloat = floor(cardHeaderHeight * cardCollapsedVisibilityPercentage)
            return UIScreen.main.bounds.size.height - safeArea.bottom - (cardTopVisibilityHeight * (numberOfVisibleCardsFloatValue - CGFloat(cardPosition)))
    
        case .hidden:
            return UIScreen.main.bounds.size.height
        }
    }
    
    func setRenderedCardsState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            removeHiddenRenderedCards(animated: animated)
                      
            setCurrentCardPosition(cardPosition: nil, animated: animated)
                        
            for cardPosition in 0 ..< renderedCards.count {
                
                cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .starting(cardPosition: cardPosition))
            }
            
        case .showingCard(let showingCardAtPosition):
            
            // nothing to show if the card is nil and we are at the cards starting positions state
            if showingCardAtPosition == nil && currentCardState == .starting {
                return
            }
            
            guard let showCardAtPosition = showingCardAtPosition else {
                setRenderedCardsState(cardsState: .collapseAllCards, animated: animated)
                return
            }
            
            setCurrentCardPosition(cardPosition: showCardAtPosition, animated: animated)
            
            removeHiddenRenderedCards(animated: animated, afterIndex: showCardAtPosition)
                                                
            for cardPosition in 0 ..< renderedCards.count {
             
                let cardTop: CGFloat
                let shouldShowCard: Bool = cardPosition <= showCardAtPosition
                
                if shouldShowCard {
                    cardTop = getCardTopConstant(state: .showing)
                }
                else {
                    cardTop = getCardTopConstant(state: .collapsed(cardPosition: cardPosition))
                }
                
                cardTopConstraints[cardPosition].constant = cardTop
            }
            
        case .showingKeyboard(let showingCardAtPosition):
                
            setCurrentCardPosition(cardPosition: showingCardAtPosition, animated: animated)
            
            for cardPosition in 0 ..< renderedCards.count {
                                
                if cardPosition <= showingCardAtPosition {
                    cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .showingKeyboard)
                }
            }
                        
        case .collapseAllCards:
                  
            setCurrentCardPosition(cardPosition: nil, animated: animated)
            
            removeHiddenRenderedCards(animated: animated)
                        
            for cardPosition in 0 ..< renderedCards.count {
                                
                cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .collapsed(cardPosition: cardPosition))
            }
            
        case .initialized:
            break
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.renderedCardsParentView?.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(cardsState: cardsState, animated: animated)
            })
        }
        else {
            renderedCardsParentView?.layoutIfNeeded()
            handleCompletedSetCardState(cardsState: cardsState, animated: animated)
        }
        
        currentCardState = cardsState
        
        delegate?.toolPageCardsDidChangeCardState(
            cardsView: self,
            cardsState: cardsState,
            animated: animated
        )
    }
    
    private func handleCompletedSetCardState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
        
        case .starting:
            break
            
        case .showingCard(let showingCardAtPosition):
            break
            
        case .showingKeyboard:
            break
                        
        case .collapseAllCards:
            setRenderedCardsState(cardsState: .starting, animated: animated)
            
        case .initialized:
            break
        }
    }
    
    private func setCurrentCardPosition(cardPosition: Int?, animated: Bool) {
        
        if currentCardPosition != cardPosition {
            
            if let currentCardPosition = currentCardPosition, let currentCardView = getRenderedCardView(cardPosition: currentCardPosition) {
                currentCardView.onCardHidden()
                currentCardView.notifyViewAndAllChildrenViewDidDisappear()
            }
            
            currentCardPosition = cardPosition
            
            if let cardPosition = cardPosition, let cardView = getRenderedCardView(cardPosition: cardPosition) {
                cardView.onCardVisible()
                cardView.notifyViewAndAllChildrenViewDidAppear()
            }
            
            delegate?.toolPageCardsDidChangeCardPosition(cardsView: self, cardPosition: cardPosition, animated: animated)
        }
    }
    
    func getCurrentCardPosition() -> Int? {
        return currentCardPosition
    }
    
    func getNumberOfRenderedCards() -> Int {
        return renderedCards.count
    }
}
