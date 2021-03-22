//
//  ToolPageCardsView.swift
//  godtools
//
//  Created by Levi Eggert on 3/21/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

protocol ToolPageCardsViewDelegate: class {
    
    func cardsViewDidChangeCardState(cardsView: ToolPageCardsView, cardsState: ToolPageCardsState, animated: Bool)
}

class ToolPageCardsView: MobileContentView {
    
    private let viewModel: ToolPageCardsViewModelType
    private let safeArea: UIEdgeInsets
    
    private var cardViews: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var cardParentContentInsets: UIEdgeInsets = .zero
    private var cardsAddedToParentView: Bool = false
    
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
        
        viewModel.currentCard.addObserver(self) { [weak self] (cardPositionAnimatable: AnimatableValue<Int?>) in
            self?.setCardsState(cardsState: .showingCard(showingCardAtPosition: cardPositionAnimatable.value), animated: cardPositionAnimatable.animated)
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
    
    // MARK: - Cards
    
    private func removeAllCardsFromParentView() {
        
        cardTopConstraints.removeAll()
        
        for cardView in cardViews {
            cardView.removeFromSuperview()
        }
        
        cardsAddedToParentView = false
    }
    
    func addCardsToView(parentView: UIView, cardParentContentInsets: UIEdgeInsets) {
        
        self.cardParentContentInsets = cardParentContentInsets
        
        if cardsAddedToParentView {
            removeAllCardsFromParentView()
        }
        
        cardsAddedToParentView = true
        
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
        }
        
        setCardsState(cardsState: .starting, animated: false)
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

    private func getCardHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height - showCardTopInset - showCardBottomInset
    }
    
    private func getCardTopConstant(state: ToolPageCardTopConstantState) -> CGFloat {
        
        let numberOfVisibleCardsFloatValue: CGFloat = CGFloat(numberOfVisibleCards)
        let cardHeaderHeight: CGFloat = ToolPageCardView.cardHeaderHeight
        
        switch state {
            
        case .starting(let cardPosition):
            return cardsContainerFrameRelativeToScreen.size.height - (cardHeaderHeight * (numberOfVisibleCardsFloatValue - CGFloat(cardPosition)))
        
        case .showing:
            return showCardTopInset
        
        case .showingKeyboard:
            return showCardTopInset
            
        case .collapsed(let cardPosition):
            let cardTopVisibilityHeight: CGFloat = floor(cardHeaderHeight * cardCollapsedVisibilityPercentage)
            return cardsTopRelativeToCardsContainerFrameBottom - (cardTopVisibilityHeight * (numberOfVisibleCardsFloatValue - CGFloat(cardPosition)))
        
        case .hidden:
            return UIScreen.main.bounds.size.height
        }
    }
    
    private func setCardsState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
                        
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
            
            for cardPosition in 0 ..< numberOfCards {
                
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if cardPosition <= showingCardAtPosition {
                    cardTopConstraint.constant = getCardTopConstant(state: .showingKeyboard)
                }
            }
                        
        case .collapseAllCards:
            
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
            break
        }
        
        delegate?.cardsViewDidChangeCardState(
            cardsView: self,
            cardsState: cardsState,
            animated: animated
        )
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(cardsState: cardsState, animated: animated)
            })
        }
        else {
            layoutIfNeeded()
            handleCompletedSetCardState(cardsState: cardsState, animated: animated)
        }
        
        currentCardState = cardsState
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
