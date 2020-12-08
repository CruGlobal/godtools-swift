//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageView: UIView {
    
    private let panGestureToControlPageCollectionViewPanningSensitivity: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
    private let keyboardObserver: KeyboardObserverType = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var viewModel: ToolPageViewModelType?
    private var safeArea: UIEdgeInsets = .zero
    private var contentStackView: MobileContentStackView?
    private var heroView: MobileContentStackView?
    private var cards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var toolModal: ToolPageModalView?
    private var cardBounceAnimation: ToolPageCardBounceAnimation?
    
    private weak var windowViewController: UIViewController?
    
    @IBOutlet weak private var backgroundImageContainer: UIView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerView: UIView!
    
    @IBOutlet weak private var headerNumberLabel: UILabel!
    @IBOutlet weak private var headerTitleLabel: UILabel!
    @IBOutlet weak private var headerTrainingTipView: UIView!
    @IBOutlet weak private var heroContainerView: UIView!
    @IBOutlet weak private var callToActionView: UIView!
    @IBOutlet weak private var callToActionTitleLabel: UILabel!
    @IBOutlet weak private var callToActionNextButton: UIButton!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var headerTop: NSLayoutConstraint!
    @IBOutlet weak private var heroTop: NSLayoutConstraint!
    @IBOutlet weak private var heroHeight: NSLayoutConstraint!
    @IBOutlet weak private var callToActionBottom: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    required init() {
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        
        callToActionNextButton.addTarget(self, action: #selector(handleCallToActionNext(button:)), for: .touchUpInside)
        
        addGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
        panGestureToControlPageCollectionViewPanningSensitivity.delegate = self
        keyboardObserver.startObservingKeyboardChanges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        keyboardObserver.stopObservingKeyboardChanges()
        keyboardObserver.keyboardStateDidChangeSignal.removeObserver(self)
        keyboardObserver.keyboardHeightDidChangeSignal.removeObserver(self)
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    func resetView() {
        
        self.viewModel = nil
    }
    
    func configure(viewModel: ToolPageViewModelType, windowViewController: UIViewController, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.windowViewController = windowViewController
        self.safeArea = safeArea
        
        topInsetTopConstraint.constant = safeArea.top
        bottomInsetBottomConstraint.constant = safeArea.bottom
        
        backgroundColor = viewModel.backgroundColor
        
        // backgroundImageView
        backgroundImageView.configure(viewModel: viewModel.backgroundImageWillAppear(), parentView: backgroundImageContainer)
        
        // headerView
        let headerViewModel: ToolPageHeaderViewModel = viewModel.headerViewModel
        
        headerView.backgroundColor = headerViewModel.backgroundColor
        
        headerNumberLabel.font = headerViewModel.headerNumberFont
        headerNumberLabel.text = headerViewModel.headerNumber
        headerNumberLabel.textColor = headerViewModel.headerNumberColor
        headerNumberLabel.textAlignment = headerViewModel.headerNumberAlignment
        
        headerTitleLabel.font = headerViewModel.headerTitleFont
        headerTitleLabel.text = headerViewModel.headerTitle
        headerTitleLabel.textColor = headerViewModel.headerTitleColor
        headerTitleLabel.setLineSpacing(lineSpacing: 2)
        headerTitleLabel.textAlignment = headerViewModel.headerTitleAlignment
        
        // headerTrainingTipView
        viewModel.hidesHeaderTrainingTip.addObserver(self) { [weak self] (hidesHeaderTrainingTip: Bool) in
            self?.headerTrainingTipView.isHidden = hidesHeaderTrainingTip
        }
        headerTrainingTipView.backgroundColor = .clear
        
        if let headerTrainingTipViewModel = viewModel.headerTrainingTipViewModel {
            
            let trainingTipView = TrainingTipView(
                viewModel: headerTrainingTipViewModel
            )
            
            headerTrainingTipView.addSubview(trainingTipView)
            trainingTipView.constrainEdgesToSuperview()
        }
            
        // callToAction
        let callToActionViewModel: ToolPageCallToActionViewModel = viewModel.callToActionViewModel
        callToActionTitleLabel.text = callToActionViewModel.callToActionTitle
        callToActionTitleLabel.textColor = callToActionViewModel.callToActionTitleColor
        callToActionNextButton.setImage(callToActionViewModel.callToActionButtonImage, for: .normal)
        callToActionNextButton.setImageColor(color: callToActionViewModel.callToActionNextButtonColor)
        
        // toolModal
        viewModel.modal.addObserver(self) { [weak self] (viewModel: ToolPageModalViewModel?) in
            if let viewModel = viewModel {
                self?.presentModal(viewModel: viewModel, animated: true)
            }
            else {
                self?.dismissModalIfNeeded(animated: true, completion: nil)
            }
        }
        
        // keyboard
        keyboardObserver.keyboardStateDidChangeSignal.addObserver(self) { [weak self] (keyboardStateChange: KeyboardStateChange) in
            self?.handleKeyboardStateChange(viewModel: viewModel, keyboardStateChange: keyboardStateChange)
        }
        
        //
        let hidesHeader: Bool = viewModel.headerViewModel.hidesHeader
        let hidesCards: Bool = viewModel.numberOfVisibleCards == 0
        let hidesCallToAction: Bool = viewModel.callToActionViewModel.hidesCallToAction
        
        // contentStack
        if let contentStackViewModel = viewModel.contentStackViewModel {
            let contentStackView: MobileContentStackView = MobileContentStackView(viewRenderer: contentStackViewModel.contentStackRenderer, itemSpacing: 20, scrollIsEnabled: true)
            contentStackContainerView.addSubview(contentStackView)
            contentStackView.constrainEdgesToSuperview()
            contentStackContainerView.isHidden = false
            contentStackContainerView.layoutIfNeeded()
            self.contentStackView = contentStackView
        }
        else {
            contentStackContainerView.isHidden = true
        }
        
        setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: hidesHeader, animated: false)
        setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: hidesCallToAction, animated: false)
                
        //cards
        if viewModel.numberOfCards > 0 {
                        
            addCardsAndCardsConstraints(cardsViewModels: viewModel.cardsViewModels)
            
            layoutIfNeeded()
            
            setCardsState(viewModel: viewModel, cardsState: .starting, animated: false)
            
            viewModel.currentCard.addObserver(self) { [weak self] (cardPositionAnimatable: AnimatableValue<Int?>) in
                self?.setCardsState(viewModel: viewModel, cardsState: .showingCard(showingCardAtPosition: cardPositionAnimatable.value), animated: cardPositionAnimatable.animated)
            }
            
            viewModel.hidesCardJump.addObserver(self) { [weak self] (hidesCardJump: Bool) in
                guard let toolPage = self else {
                    return
                }
                
                if hidesCardJump, let cardBounceAnimation = self?.cardBounceAnimation {
                    cardBounceAnimation.stopAnimation(forceStop: true)
                }
                else if !hidesCardJump, let firstCard = self?.cards.first, let firstContraint = self?.cardTopConstraints.first {
                    
                    let cardBounceAnimation = ToolPageCardBounceAnimation(
                        card: firstCard,
                        cardTopConstraint: firstContraint,
                        cardStartingTopConstant: toolPage.getCardTopConstant(state: .starting(cardPosition: 0)),
                        layoutView: toolPage,
                        delegate: toolPage
                    )
                    cardBounceAnimation.startAnimation()
                    self?.cardBounceAnimation = cardBounceAnimation
                }
            }
        }
        
        // hero top and height
        if let heroViewModel = viewModel.heroViewModel {
            
            let topInset: CGFloat = 15
            let bottomInset: CGFloat = 0
            let screenHeight: CGFloat = UIScreen.main.bounds.size.height
            let headerHeight: CGFloat = hidesHeader ? 0 : headerView.frame.size.height
            let maximumHeight: CGFloat = screenHeight - safeArea.top - safeArea.bottom - headerHeight - topInset - bottomInset
            
            if hidesCards && hidesCallToAction {
                heroHeight.constant = maximumHeight
            }
            else if hidesCards && !hidesCallToAction {
                heroHeight.constant = maximumHeight - callToActionView.frame.size.height
            }
            else if !hidesCards {
                
                guard let cardView = cards.first else {
                    assertionFailure("Cards should be initialized and added at this point.")
                    return
                }
                
                let numberOfVisibleCards: CGFloat =  CGFloat(viewModel.numberOfVisibleCards)
                let cardTitleHeight: CGFloat = cardView.cardHeaderHeight
                heroHeight.constant = maximumHeight - (numberOfVisibleCards * cardTitleHeight)
            }
                         
            heroTop.constant = headerHeight + topInset
                                    
            let heroView: MobileContentStackView = MobileContentStackView(viewRenderer: heroViewModel.contentStackRenderer, itemSpacing: 20, scrollIsEnabled: true)
            heroContainerView.addSubview(heroView)
            heroView.constrainEdgesToSuperview()
            heroContainerView.isHidden = false
            self.heroView = heroView
            
            heroContainerView.layoutIfNeeded()
            layoutIfNeeded()
        }
        else {
            heroContainerView.isHidden = true
        }
    }
    
    @objc func handleCallToActionNext(button: UIButton) {
        viewModel?.callToActionNextButtonTapped()
    }
    
    private func setHeroContentInsets(hidesHeader: Bool) {
        
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
    
    private func setHeaderHidden(headerViewModel: ToolPageHeaderViewModel, hidden: Bool, animated: Bool) {
                    
        if headerViewModel.hidesHeader && !hidden {
            return
        }
        
        let topConstant: CGFloat = hidden ? headerView.frame.size.height * -1 : 0
        let headerAlpha: CGFloat = hidden ? 0 : 1
        
        headerTop.constant = topConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
                self.headerView.alpha = headerAlpha
                self.headerTrainingTipView.alpha = headerAlpha
            }, completion: nil)
        }
        else {
            layoutIfNeeded()
            headerView.alpha = headerAlpha
            headerTrainingTipView.alpha = headerAlpha
        }
    }
    
    private func setCallToActionHidden(callToActionViewModel: ToolPageCallToActionViewModel, hidden: Bool, animated: Bool) {
        
        if callToActionViewModel.hidesCallToAction && !hidden {
            return
        }
        
        let bottomConstant: CGFloat = hidden ? callToActionView.frame.size.height : 0
        let callToActionAlpha: CGFloat = hidden ? 0 : 1
        
        callToActionBottom.constant = bottomConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
                self.callToActionView.alpha = callToActionAlpha
            }, completion: nil)
        }
        else {
            layoutIfNeeded()
            callToActionView.alpha = callToActionAlpha
        }
    }
}

// MARK: - ToolPageCardBounceAnimationDelegate

extension ToolPageView: ToolPageCardBounceAnimationDelegate {
    func toolPageCardBounceAnimationDidFinish(cardBounceAnimation: ToolPageCardBounceAnimation, forceStopped: Bool) {
        viewModel?.cardBounceAnimationFinished()
    }
}

// MARK: - Modal

extension ToolPageView {
    
    private func presentModal(viewModel: ToolPageModalViewModel, animated: Bool) {
        
        guard toolModal == nil, let window = self.windowViewController else {
            return
        }
        
        let toolModal: ToolPageModalView = ToolPageModalView(viewModel: viewModel)
        
        window.view.addSubview(toolModal)
        toolModal.frame = window.view.bounds
                        
        self.toolModal = toolModal
        
        if animated {
            toolModal.alpha = 0
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                toolModal.alpha = 1
            }, completion: nil)
        }
    }
    
    private func dismissModalIfNeeded(animated: Bool, completion: (() -> Void)?) {
        
        guard let toolModalView = self.toolModal else {
            completion?()
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                toolModalView.alpha = 0
            }) { (finished: Bool) in
                toolModalView.removeFromSuperview()
                completion?()
            }
        }
        else {
            toolModalView.alpha = 0
            toolModalView.removeFromSuperview()
            completion?()
        }
    }
}

// MARK: - Cards Constraints and State

extension ToolPageView {
    
    private var cardInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    private var cardsContainerFrameRelativeToScreen: CGRect {
        let screenSize: CGSize = UIScreen.main.bounds.size
        let top: CGFloat = safeArea.top
        let height: CGFloat = screenSize.height - top - safeArea.bottom
        return CGRect(x: 0, y: top, width: screenSize.width, height: height)
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
            return cardsContainerHeight - callToActionView.frame.size.height - cardInsets.top - cardInsets.bottom
        }
                
        let numberOfVisibleCards: CGFloat = CGFloat(viewModel?.numberOfVisibleCards ?? 0)
        let cardTitleHeight: CGFloat = cardView.cardHeaderHeight
        let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
        let collapsedCardsHeight: CGFloat = (cardTopVisibilityHeight * (numberOfVisibleCards - 1))
        
        let callToActionHeight: CGFloat = callToActionView.frame.size.height
        
        let maxFooterAreaHeight: CGFloat = (collapsedCardsHeight > callToActionHeight) ? collapsedCardsHeight : callToActionHeight
        
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
        
        switch cardsState {
            
        case .starting:
            
            setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: false, animated: animated)
            setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: true, animated: animated)
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cards.count {
                
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
            
            setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: true, animated: animated)
            
            let isShowingLastVisibleCard: Bool = showCardAtPosition >= viewModel.numberOfVisibleCards - 1
            
            setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: !isShowingLastVisibleCard, animated: animated)
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cards.count {
                
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
            
            for cardPosition in 0 ..< cards.count {
                
                let cardTopConstraint: NSLayoutConstraint = cardTopConstraints[cardPosition]
                
                if cardPosition <= showingCardAtPosition {
                    cardTopConstraint.constant = getCardTopConstant(state: .showingKeyboard)
                }
            }
                        
        case .collapseAllCards:
            
            var visibleCardPosition: Int = 0
            
            for cardPosition in 0 ..< cards.count {
                
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
                self.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleCompletedSetCardState(viewModel: viewModel, cardsState: cardsState, animated: animated)
            })
        }
        else {
            layoutIfNeeded()
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
    
    private func addCardsAndCardsConstraints(cardsViewModels: [ToolPageCardViewModelType]) {
        
        for cardViewModel in cardsViewModels {
            
            let cardView: ToolPageCardView = ToolPageCardView(viewModel: cardViewModel)
            
            cards.append(cardView)
            
            addSubview(cardView)

            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1,
                constant: cardInsets.top
            )
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: cardInsets.left
            )
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: cardInsets.right * -1
            )
            
            addConstraint(top)
            addConstraint(leading)
            addConstraint(trailing)
            
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
        }
    }
}

// MARK: - Keyboard

extension ToolPageView {
    
    func handleKeyboardStateChange(viewModel: ToolPageViewModelType, keyboardStateChange: KeyboardStateChange) {
        
        guard let currentCardPosition = viewModel.currentCard.value.value else {
            return
        }
        
        guard currentCardPosition >= 0 && currentCardPosition < cards.count else {
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

// MARK: - UIGestureRecognizerDelegate

extension ToolPageView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
           
        if gestureRecognizer == panGestureToControlPageCollectionViewPanningSensitivity {
                        
            if let otherView = otherGestureRecognizer.view, otherView is UICollectionView, let collectionViewPanGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
                
                let velocity: CGPoint = collectionViewPanGesture.velocity(in: self)
                        
                let angleRadians: CGFloat = atan2(velocity.y, velocity.x)
                var angleDegrees: CGFloat = angleRadians * 57.2958
                if angleDegrees < 0 {
                    angleDegrees *= -1
                }
                let rightToLeftDegrees: CGFloat = 180
                let leftToRightDegrees: CGFloat = 0
                let allowedPanOffsetDegrees: CGFloat = 40
                                                    
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
                
                // Allow simultaneous gestures whenever the pan gesture is active against any gesture that is not a collectionview.
                return true
            }
        }
        
        return true
    }
}
