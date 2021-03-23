//
//  ToolPageCardsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardsViewDelegate: class {
    
    func toolPageCardsViewDidChangeCardState(cardsView: ToolPageCardsView, cardsState: ToolPageCardsState, animated: Bool)
}

class ToolPageCardsView: MobileContentView {
    
    private let viewModel: ToolPageCardsViewModelType
    private let safeArea: UIEdgeInsets
    
    private var cardBounceAnimation: ToolPageCardBounceAnimation?
    private var cardViews: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var cardParentContentInsets: UIEdgeInsets = .zero
    private var currentCardPosition: Int?
    
    private weak var cardsParentView: UIView?
    private weak var delegate: ToolPageCardsViewDelegate?
    
    required init(viewModel: ToolPageCardsViewModelType, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
    }
    
    private func addCardJumpObserving() {
        
        viewModel.hidesCardJump.addObserver(self) { [weak self] (hidesCardJump: Bool) in
            
            guard let cardsView = self else {
                return
            }
            
            let firstCard: ToolPageCardView? = cardsView.cardViews.first
            let firstCardTopConstraint: NSLayoutConstraint? = cardsView.cardTopConstraints.first
            let cardsParent: UIView? = cardsView.cardsParentView
            
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
            cardViews.append(cardView)
        }
    }
    
    // MARK: -
    
    func setDelegate(delegate: ToolPageCardsViewDelegate) {
        self.delegate = delegate
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
        
        guard let cardPosition = getCardPosition(cardView: cardView) else {
            return
        }
        
        viewModel.cardHeaderTapped()
        
        if cardPosition != currentCardPosition {
            setCardsState(cardsState: .showingCard(showingCardAtPosition: cardPosition), animated: true)
        }
        else {
            setCardsState(cardsState: .collapseAllCards, animated: true)
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
        
        let previousCard: Int = cardPosition - 1
        
        if previousCard >= 0 {
            setCardsState(cardsState: .showingCard(showingCardAtPosition: previousCard), animated: animated)
        }
        else {
            setCardsState(cardsState: .showingCard(showingCardAtPosition: nil), animated: animated)
        }
    }
    
    private func gotoNextCard(animated: Bool) {
        
        guard let cardPosition = currentCardPosition else {
            return
        }
        
        let nextCard: Int = cardPosition + 1
        
        guard nextCard < numberOfVisibleCards else {
            return
        }
        
        setCardsState(cardsState: .showingCard(showingCardAtPosition: nextCard), animated: animated)
    }
}

// MARK: - Cards

extension ToolPageCardsView {
       
    private func getCardPosition(cardView: ToolPageCardView) -> Int? {
        return cardViews.firstIndex(of: cardView)
    }
    
    private func removeAllCardsFromParentView() {
        
        cardTopConstraints.removeAll()
        
        for cardView in cardViews {
            cardView.removeFromSuperview()
            cardView.setDelegate(delegate: nil)
        }
    }
    
    func addCardsToView(parentView: UIView, cardParentContentInsets: UIEdgeInsets) {
        
        self.cardParentContentInsets = cardParentContentInsets
        
        if cardsParentView != nil {
            removeAllCardsFromParentView()
            cardsParentView = nil
        }
        
        cardsParentView = parentView
        
        for cardView in cardViews {
            
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
                constant: getCardHeight()
            )
            
            cardView.addConstraint(heightConstraint)
            
            cardTopConstraints.append(top)
            
            cardView.setDelegate(delegate: self)
        }
        
        setCardsState(cardsState: .starting, animated: false)
        
        addCardJumpObserving()
    }
    
    private var numberOfCards: Int {
        return viewModel.numberOfCards
    }
    
    var numberOfVisibleCards: Int {
        return viewModel.numberOfVisibleCards
    }
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var showCardTopInset: CGFloat {
        return safeArea.top + cardParentContentInsets.top + cardInsets.top
    }
    
    private var showCardBottomInset: CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(numberOfVisibleCards)
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

    private func getCardHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height - showCardTopInset - showCardBottomInset
    }
    
    private func getCardTopConstant(state: ToolPageCardTopConstantState) -> CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(numberOfVisibleCards)
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
    
    private func setCardsState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
                 
            currentCardPosition = nil
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cardViews.count {
             
                let cardViewModel: ToolPageCardViewModelType = cardViews[cardPosition].viewModel
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
                setCardsState(cardsState: .collapseAllCards, animated: animated)
                return
            }
            
            currentCardPosition = showingCardAtPosition
                        
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cardViews.count {
             
                let cardViewModel: ToolPageCardViewModelType = cardViews[cardPosition].viewModel
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
            
            currentCardPosition = showingCardAtPosition
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if cardPosition <= showingCardAtPosition {
                    cardTopConstraint.constant = getCardTopConstant(state: .showingKeyboard)
                }
            }
                        
        case .collapseAllCards:
            
            currentCardPosition = nil
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cardViews.count {
                
                let cardViewModel: ToolPageCardViewModelType = cardViews[cardPosition].viewModel
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
            
            currentCardPosition = nil
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.cardsParentView?.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(cardsState: cardsState, animated: animated)
            })
        }
        else {
            cardsParentView?.layoutIfNeeded()
            handleCompletedSetCardState(cardsState: cardsState, animated: animated)
        }
        
        currentCardState = cardsState
        
        delegate?.toolPageCardsViewDidChangeCardState(
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
            setCardsState(cardsState: .starting, animated: animated)
            
        case .initialized:
            break
        }
    }
}
