//
//  TractPageCardsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit
import GodToolsToolParser

protocol TractPageCardsViewDelegate: AnyObject {
    
    func tractPageCardsDidChangeCardState(cardsView: TractPageCardsView, cardsState: TractPageCardsState, animated: Bool)
    func tractPageCardsDidChangeCardPosition(cardsView: TractPageCardsView, cardPosition: Int?, animated: Bool)
}

class TractPageCardsView: MobileContentView {
    
    private let viewModel: TractPageCardsViewModel
    private let safeArea: UIEdgeInsets
    private let keyboardObserver: KeyboardNotificationObserver = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var cardBounceAnimation: TractPageCardBounceAnimation?
    private var allCards: [TractPageCardView] = Array()
    private var renderedCards: [TractPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: TractPageCardsState = .initialized
    private var cardParentContentInsets: UIEdgeInsets = .zero
    private var currentCardPosition: Int?
    private var isObservingCardJump: Bool = false
    
    private weak var renderedCardsParentView: UIView?
    private weak var delegate: TractPageCardsViewDelegate?
    
    init(viewModel: TractPageCardsViewModel, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        keyboardObserver.startObservingKeyboardChanges(delegate: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        keyboardObserver.stopObservingKeyboardChanges()
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
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
            
            let firstCard: TractPageCardView? = cardsView.renderedCards.first
            let firstCardTopConstraint: NSLayoutConstraint? = cardsView.cardTopConstraints.first
            let cardsParent: UIView? = cardsView.renderedCardsParentView
            
            if hidesCardJump, let cardBounceAnimation = self?.cardBounceAnimation {
                cardBounceAnimation.stopAnimation(forceStop: true)
            }
            else if !hidesCardJump, let firstCard = firstCard, let firstCardTopConstraint = firstCardTopConstraint, let cardsParent = cardsParent {
                
                let cardBounceAnimation = TractPageCardBounceAnimation(
                    card: firstCard,
                    cardTopConstraint: firstCardTopConstraint,
                    cardStartingTopConstant: cardsView.getCardTopConstant(state: .starting, cardPosition: 0),
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
        
        if let cardView = childView as? TractPageCardView {
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
    
    func setCardsViewDelegate(delegate: TractPageCardsViewDelegate) {
        self.delegate = delegate
    }
    
    private func dismissCard(cardView: TractPageCardView) {
        
        guard let cardPosition = getRenderedCardPosition(cardView: cardView) else {
            return
        }
            
        gotoPreviousCardFromCardPosition(cardPosition: cardPosition, animated: true)
    }
    
    private func presentCard(cardView: TractPageCardView) {
          
        addCardToRenderedCards(cardView: cardView)
        
        guard let cardPosition = getRenderedCardPosition(cardView: cardView) else {
            return
        }
        
        setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: cardPosition), animated: true)
    }
}

// MARK: - KeyboardNotificationObserverDelegate

extension TractPageCardsView: KeyboardNotificationObserverDelegate {
    
    func keyboardStateDidChange(keyboardObserver: KeyboardNotificationObserver, keyboardStateChange: KeyboardStateChange) {
        
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
    
    func keyboardHeightDidChange(keyboardObserver: KeyboardNotificationObserver, keyboardHeight: Double) {
        
    }
}

// MARK: - TractPageCardBounceAnimationDelegate

extension TractPageCardsView: TractPageCardBounceAnimationDelegate {
    func tractPageCardBounceAnimationDidFinish(cardBounceAnimation: TractPageCardBounceAnimation, forceStopped: Bool) {
        viewModel.cardBounceAnimationFinished()
    }
}

// MARK: - TractPageCardViewDelegate

extension TractPageCardsView: TractPageCardViewDelegate {
    
    func tractPageCardHeaderTapped(cardView: TractPageCardView) {
        
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
    
    func tractPageCardPreviousTapped(cardView: TractPageCardView) {
        
        gotoPreviousCard(animated: true)
    }
    
    func tractPageCardNextTapped(cardView: TractPageCardView) {
        
        gotoNextCard(animated: true)
    }
    
    func tractPageCardDidSwipeCardUp(cardView: TractPageCardView) {
        
        viewModel.cardSwipedUp()
        
        gotoNextCard(animated: true)
    }
    
    func tractPageCardDidSwipeCardDown(cardView: TractPageCardView) {
                
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

extension TractPageCardsView {
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var showCardTopInset: CGFloat {
        return safeArea.top + cardParentContentInsets.top + cardInsets.top
    }
    
    private var showCardBottomInset: CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(allCards.filter({!$0.isHidden}).count)
        let cardTopVisibilityHeight: CGFloat = floor(TractPageCardView.minimumCardHeaderHeight * cardCollapsedVisibilityPercentage)
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
    
    private func addCardToRenderedCards(cardView: TractPageCardView) {
        
        guard let cardsParentView = renderedCardsParentView else {
            return
        }
        
        guard !renderedCards.contains(cardView) else {
            return
        }
        
        renderedCards.append(cardView)
        
        let cardPosition: Int = getRenderedCardPosition(cardView: cardView) ?? 0
        
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
        
        top.constant = getCardTopConstant(state: .hidden, cardPosition: cardPosition)
                    
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
    
    private func removeHiddenCardFromRenderedCards(cardView: TractPageCardView, animated: Bool) {
        
        guard cardView.isHiddenCard && renderedCards.contains(cardView) else {
            return
        }
        
        if animated, let cardPosition = getRenderedCardPosition(cardView: cardView) {
            
            cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .hidden, cardPosition: cardPosition)
            
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
    
    private func removeRenderedCard(cardView: TractPageCardView, shouldRemoveFromView: Bool) {
        
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
    
    private func getRenderedCardPosition(cardView: TractPageCardView) -> Int? {
        return renderedCards.firstIndex(of: cardView)
    }
    
    private func getRenderedCardView(cardPosition: Int) -> TractPageCardView? {
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
    
    private func getCardTopConstant(state: TractPageCardTopConstantState, cardPosition: Int) -> CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(renderedCards.count)
        
        switch state {
            
        case .starting:
            
            var combinedCardHeaderHeightsFollowingCardPosition: CGFloat = 0
            
            for index in cardPosition ..< renderedCards.count {
                combinedCardHeaderHeightsFollowingCardPosition += renderedCards[index].getCardHeaderHeight()
            }
            
            return UIScreen.main.bounds.size.height - safeArea.bottom - combinedCardHeaderHeightsFollowingCardPosition
        
        case .showing:
            return showCardTopInset
        
        case .showingKeyboard:
            return showCardTopInset
            
        case .collapsed:
            let cardTopVisibilityHeight: CGFloat = floor(TractPageCardView.minimumCardHeaderHeight * cardCollapsedVisibilityPercentage)
            return UIScreen.main.bounds.size.height - safeArea.bottom - (cardTopVisibilityHeight * (numberOfVisibleCardsFloatValue - CGFloat(cardPosition)))
    
        case .hidden:
            return UIScreen.main.bounds.size.height
        }
    }
    
    func setRenderedCardsState(cardsState: TractPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            removeHiddenRenderedCards(animated: animated)
                      
            setCurrentCardPosition(cardPosition: nil, animated: animated)
                        
            for cardPosition in 0 ..< renderedCards.count {
                
                cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .starting, cardPosition: cardPosition)
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
                    cardTop = getCardTopConstant(state: .showing, cardPosition: cardPosition)
                }
                else {
                    cardTop = getCardTopConstant(state: .collapsed, cardPosition: cardPosition)
                }
                
                cardTopConstraints[cardPosition].constant = cardTop
            }
            
        case .showingKeyboard(let showingCardAtPosition):
                
            setCurrentCardPosition(cardPosition: showingCardAtPosition, animated: animated)
            
            for cardPosition in 0 ..< renderedCards.count where cardPosition <= showingCardAtPosition {
                                
                cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .showingKeyboard, cardPosition: cardPosition)
            }
                        
        case .collapseAllCards:
                  
            setCurrentCardPosition(cardPosition: nil, animated: animated)
            
            removeHiddenRenderedCards(animated: animated)
                        
            for cardPosition in 0 ..< renderedCards.count {
                                
                cardTopConstraints[cardPosition].constant = getCardTopConstant(state: .collapsed, cardPosition: cardPosition)
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
        
        delegate?.tractPageCardsDidChangeCardState(
            cardsView: self,
            cardsState: cardsState,
            animated: animated
        )
    }
    
    private func handleCompletedSetCardState(cardsState: TractPageCardsState, animated: Bool) {
        
        switch cardsState {
        
        case .starting:
            break
            
        case .showingCard( _):
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
            
            delegate?.tractPageCardsDidChangeCardPosition(cardsView: self, cardPosition: cardPosition, animated: animated)
        }
    }
    
    func getCurrentCardPosition() -> Int? {
        return currentCardPosition
    }
    
    func getNumberOfRenderedCards() -> Int {
        return renderedCards.count
    }
    
    func getCombinedCardHeaderHeightForRenderedCards() -> CGFloat? {
        
        guard renderedCards.count >= 0 else {
            return nil
        }
        
        var combinedCardsHeaderHeight: CGFloat = 0
        
        for card in renderedCards {
            combinedCardsHeaderHeight += card.getCardHeaderHeight()
        }
        
        return combinedCardsHeaderHeight
    }
}
