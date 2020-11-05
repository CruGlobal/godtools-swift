//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageView: UIViewController {
    
    enum CardsState {
        case starting
        case showingCard(showingCardAtPosition: Int)
    }
    
    enum CardTopConstantState {
        case starting
        case showing
        case hidden
    }
    
    class PanningCard {
        let card: ToolPageCardView
        let cardPosition: Int
        required init(card: ToolPageCardView, cardPosition: Int) {
            self.card = card
            self.cardPosition = cardPosition
        }
    }
    
    private let viewModel: ToolPageViewModelType
    private let cardPanGesture: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var contentStackView: ToolPageContentStackView?
    private var heroView: ToolPageContentStackView?
    private var cards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var panningCard: PanningCard?
    private var panningPoint: CGPoint = CGPoint.zero
    private var lastPanningPoint: CGPoint = CGPoint.zero
    private var panVelocity: CGPoint = CGPoint.zero
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var headerNumberLabel: UILabel!
    @IBOutlet weak private var headerTitleLabel: UILabel!
    @IBOutlet weak private var heroContainerView: UIView!
    @IBOutlet weak private var cardsContainerView: UIView!
    @IBOutlet weak private var callToActionView: UIView!
    @IBOutlet weak private var callToActionTitleLabel: UILabel!
    @IBOutlet weak private var callToActionNextButton: UIButton!
    
    @IBOutlet weak private var headerTop: NSLayoutConstraint!
    @IBOutlet weak private var heroHeight: NSLayoutConstraint!
    @IBOutlet weak private var callToActionBottom: NSLayoutConstraint!
    
    required init(viewModel: ToolPageViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: ToolPageView.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view didload: \(type(of: self))")
                
        setupLayout()
        setupBinding()
        
        callToActionNextButton.addTarget(self, action: #selector(handleCallToActionNext(button:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
        
        // contentStack
        if let contentStackViewModel = viewModel.contentStackViewModel {
            let contentStackView: ToolPageContentStackView = ToolPageContentStackView(viewModel: contentStackViewModel)
            contentStackContainerView.addSubview(contentStackView)
            contentStackView.constrainEdgesToSuperview()
            contentStackContainerView.isHidden = false
            contentStackContainerView.layoutIfNeeded()
            self.contentStackView = contentStackView
        }
        else {
            contentStackContainerView.isHidden = true
        }
        
        // hero
        if let heroViewModel = viewModel.heroViewModel {
            let heroView: ToolPageContentStackView = ToolPageContentStackView(viewModel: heroViewModel)
            heroContainerView.addSubview(heroView)
            heroView.constrainEdgesToSuperview()
            heroContainerView.isHidden = false
            heroHeight.constant = view.frame.size.height
            heroContainerView.layoutIfNeeded()
            self.heroView = heroView
            view.layoutIfNeeded()
        }
        else {
            heroContainerView.isHidden = true
        }
        
        setHeaderHidden(hidden: viewModel.headerViewModel.hidesHeader, animated: false)
        setCallToActionHidden(hidden: viewModel.callToActionViewModel.hidesCallToAction, animated: false)
        setHeroTopContentInset(hidesHeader: viewModel.headerViewModel.hidesHeader)
        
        //cards
        if !viewModel.cardsViewModels.isEmpty {
            
            cardPanGesture.addTarget(self, action: #selector(handleCardPanGesture))
            view.addGestureRecognizer(cardPanGesture)
            cardPanGesture.delegate = self
            
            addCardsAndCardsConstraints(cardsViewModels: viewModel.cardsViewModels)
            
            cardsContainerView.layoutIfNeeded()
            
            setCardsState(cardsState: .starting, animated: false)
            
            viewModel.currentCard.addObserver(self) { [weak self] (cardPosition: Int?) in
                if let cardPosition = cardPosition {
                    self?.setCardsState(cardsState: .showingCard(showingCardAtPosition: cardPosition), animated: true)
                }
                else {
                    self?.setCardsState(cardsState: .starting, animated: true)
                }
            }
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        // backgroundImageView
        backgroundImageView.image = viewModel.backgroundImage
        backgroundImageView.isHidden = viewModel.hidesBackgroundImage
        
        // headerView
        let headerViewModel: ToolPageHeaderViewModel = viewModel.headerViewModel
        headerView.backgroundColor = headerViewModel.backgroundColor
        headerNumberLabel.font = headerViewModel.headerNumberFont
        headerNumberLabel.text = headerViewModel.headerNumber
        headerNumberLabel.textColor = headerViewModel.primaryTextColor
        headerTitleLabel.font = headerViewModel.headerTitleFont
        headerTitleLabel.text = headerViewModel.headerTitle
        headerTitleLabel.textColor = headerViewModel.primaryTextColor
        headerTitleLabel.setLineSpacing(lineSpacing: 2)
        
        // cards
        cardsContainerView.isHidden = viewModel.hidesCards
        
        // callToAction
        let callToActionViewModel: ToolPageCallToActionViewModel = viewModel.callToActionViewModel
        callToActionTitleLabel.text = callToActionViewModel.callToActionTitle
        callToActionTitleLabel.textColor = callToActionViewModel.callToActionTitleColor
        callToActionNextButton.setImageColor(color: callToActionViewModel.callToActionNextButtonColor)
    }
    
    @objc func handleCallToActionNext(button: UIButton) {
        viewModel.handleCallToActionNextButtonTapped()
    }
    
    private func setHeroTopContentInset(hidesHeader: Bool) {
        
        let heroTopContentInset: CGFloat
        if !hidesHeader {
            heroTopContentInset = headerView.frame.size.height + 20
        }
        else {
            heroTopContentInset = 30
        }
        heroView?.setContentInset(contentInset: UIEdgeInsets(top: heroTopContentInset, left: 0, bottom: 0, right: 0))
        heroView?.setContentOffset(contentOffset: CGPoint(x: 0, y: heroTopContentInset * -1))
    }
    
    private func setHeaderHidden(hidden: Bool, animated: Bool) {
            
        if viewModel.headerViewModel.hidesHeader && !hidden {
            return
        }
        
        let topConstant: CGFloat = hidden ? headerView.frame.size.height * -1 : 0
        
        headerTop.constant = topConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
    
    private func setCallToActionHidden(hidden: Bool, animated: Bool) {
        
        if viewModel.callToActionViewModel.hidesCallToAction && !hidden {
            return
        }
        
        let bottomConstant: CGFloat = hidden ? callToActionView.frame.size.height * -1 : 0
        
        callToActionBottom.constant = bottomConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
}

// MARK: - Cards Constraints and State

extension ToolPageView {
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var cardHeight: CGFloat {
        return cardsContainerView.frame.size.height - callToActionView.frame.size.height - cardInsets.top - cardInsets.bottom
    }
    
    private func getCardTopConstraint(cardPosition: Int) -> NSLayoutConstraint? {
        if cardPosition >= 0 && cardPosition < cardTopConstraints.count {
            return cardTopConstraints[cardPosition]
        }
        return nil
    }
    
    private func getCardTopConstant(state: CardTopConstantState, cardPosition: Int) -> CGFloat {
        
        guard let cardView = cards.first else {
            return UIScreen.main.bounds.size.height
        }
        
        let cardsContainerHeight: CGFloat = cardsContainerView.frame.size.height
        let numberOfCards: CGFloat = CGFloat(cards.count)
        let cardTitleHeight: CGFloat = cardView.titleHeight
        
        switch state {
            
        case .starting:
            return cardsContainerHeight - (cardTitleHeight * (numberOfCards - CGFloat(cardPosition)))
        case .showing:
            return cardInsets.top
        case .hidden:
            let cardTopVisibilityPercentage: CGFloat = 0.4
            let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardTopVisibilityPercentage)
            return cardsContainerHeight - (cardTopVisibilityHeight * (numberOfCards - CGFloat(cardPosition)))
        }
    }
    
    private func setCardsState(cardsState: CardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            setHeaderHidden(hidden: false, animated: animated)
            setCallToActionHidden(hidden: true, animated: animated)
            
            for index in 0 ..< cardTopConstraints.count {
                let topConstraint: NSLayoutConstraint = cardTopConstraints[index]
                topConstraint.constant = getCardTopConstant(state: .starting, cardPosition: index)
            }
            
        case .showingCard(let showingCardAtPosition):
            
            setHeaderHidden(hidden: true, animated: animated)
            
            let isShowingLastCard: Bool = showingCardAtPosition >= cards.count - 1
            
            setCallToActionHidden(hidden: !isShowingLastCard, animated: animated)
            
            for index in 0 ..< cardTopConstraints.count {
                
                let topConstraint: NSLayoutConstraint = cardTopConstraints[index]
                let shouldShowCard: Bool = index <= showingCardAtPosition
                
                if shouldShowCard {
                    topConstraint.constant = getCardTopConstant(state: .showing, cardPosition: index)
                }
                else {
                    topConstraint.constant = getCardTopConstant(state: .hidden, cardPosition: index)
                }
            }
        }
        
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(cardsState: cardsState, animated: animated)
            })
        }
        else {
            view.layoutIfNeeded()
            handleCompletedSetCardState(cardsState: cardsState, animated: animated)
        }
    }
    
    private func handleCompletedSetCardState(cardsState: CardsState, animated: Bool) {
        
        switch cardsState {
        case .starting:
            break
        case .showingCard(let showingCardAtPosition):
            if showingCardAtPosition < 0 {
                setCardsState(cardsState: .starting, animated: animated)
            }
        }
    }
    
    private func addCardsAndCardsConstraints(cardsViewModels: [ToolPageCardViewModelType]) {
        
        for cardViewModel in cardsViewModels {
            
            let cardView: ToolPageCardView = ToolPageCardView(viewModel: cardViewModel)
            
            cardsContainerView.addSubview(cardView)

            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .top,
                relatedBy: .equal,
                toItem: cardsContainerView,
                attribute: .top,
                multiplier: 1,
                constant: cardInsets.top
            )
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: cardsContainerView,
                attribute: .leading,
                multiplier: 1,
                constant: cardInsets.left
            )
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: cardsContainerView,
                attribute: .trailing,
                multiplier: 1,
                constant: cardInsets.right * -1
            )
            
            cardsContainerView.addConstraint(top)
            cardsContainerView.addConstraint(leading)
            cardsContainerView.addConstraint(trailing)
            
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
            
            cards.append(cardView)
            cardTopConstraints.append(top)
        }
    }
}

// MARK: - Card Panning

extension ToolPageView {
    
    private func getCardForPanningAtTouchPoint(touchPoint: CGPoint) -> PanningCard? {
        
        var topMostCard: ToolPageCardView?
        var topMostCardPosition: Int?
        
        for index in 0 ..< cards.count {
            
            let card: ToolPageCardView = cards[index]

            if card.frame.contains(touchPoint) {
                topMostCard = card
                topMostCardPosition = index
            }
        }
        
        if let card = topMostCard, let cardPosition = topMostCardPosition {
            return PanningCard(card: card, cardPosition: cardPosition)
        }
        
        return nil
    }
    
    private func handleCardPanningEnded() {
        
        panningCard = nil
        panningPoint = CGPoint.zero
        lastPanningPoint = CGPoint.zero
        panVelocity = CGPoint.zero
    }
    
    @objc func handleCardPanGesture() {
        
        let touchPoint: CGPoint = cardPanGesture.location(in: view)
        
        panningPoint = cardPanGesture.translation(in: view)
        panVelocity = cardPanGesture.velocity(in: view)
        
        print("\n HANDLE CARD PAN GESTURE")
        print("  cardPanGesture.state: \(cardPanGesture.state)")
        print("   touchPoint: \(touchPoint)")
        print("   panningPoint: \(panningPoint)")
        print("   panVelocity: \(panVelocity)")
        
        switch cardPanGesture.state {
            
        case .possible:
            break
            
        case .began:
            
            lastPanningPoint = panningPoint
            panningCard = getCardForPanningAtTouchPoint(touchPoint: touchPoint)
            
        case .changed:
            guard let panningCard = self.panningCard, let cardTopConstraint = getCardTopConstraint(cardPosition: panningCard.cardPosition) else {
                return
            }
            
            let translateY: CGFloat = panningPoint.y - lastPanningPoint.y
            
            print("  translate y: \(translateY)")
            
            cardTopConstraint.constant += translateY
                
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
                        
            lastPanningPoint = panningPoint
            
        case .ended:
            handleCardPanningEnded()
            
        case .cancelled:
            handleCardPanningEnded()
            
        case .failed:
            handleCardPanningEnded()
        }
    }
}

extension ToolPageView: UIGestureRecognizerDelegate {
    
    var shouldDecreaseToolPageCollectionViewPanningSensitivity: Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer == cardPanGesture {
                
            print("\n Pan Gesture")
            print("  otherView: \(otherGestureRecognizer.view)")
            print("  otherGestureRecognizer: \(otherGestureRecognizer)")
            
            if let otherView = otherGestureRecognizer.view, otherView is UICollectionView, let toolPanGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
                
                let velocity: CGPoint = toolPanGesture.velocity(in: view)
                        
                let angleRadians: CGFloat = atan2(velocity.y, velocity.x)
                var angleDegrees: CGFloat = angleRadians * 57.2958
                if angleDegrees < 0 {
                    angleDegrees *= -1
                }
                let rightToLeftDegrees: CGFloat = 180
                let leftToRightDegrees: CGFloat = 0
                let allowedPanOffsetDegrees: CGFloat = 20
                                    
                let shouldRecognizeToolPanning: Bool
                
                if angleDegrees >= rightToLeftDegrees - allowedPanOffsetDegrees && angleDegrees <= rightToLeftDegrees + allowedPanOffsetDegrees {
                    shouldRecognizeToolPanning = true
                }
                else if angleDegrees >= leftToRightDegrees - allowedPanOffsetDegrees && angleDegrees <= leftToRightDegrees + allowedPanOffsetDegrees {
                    shouldRecognizeToolPanning = true
                }
                else {
                    shouldRecognizeToolPanning = false
                }
                
                return shouldRecognizeToolPanning
            }
            else {

                // Allow simultaneous gestures whenever the tool card pan gesture is active against any gesture that is not the tool collection view pan gesture.
                return true
            }
        }
        
        return false
    }
}
