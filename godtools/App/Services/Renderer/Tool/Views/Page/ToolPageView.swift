//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import UIKit

class ToolPageView: UIView {
    
    private let viewModel: ToolPageViewModelType
    private let safeArea: UIEdgeInsets
    private let panGestureToControlPageCollectionViewPanningSensitivity: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
    private let keyboardObserver: KeyboardObserverType = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var headerView: ToolPageHeaderView?
    private var heroView: ToolPageHeroView?
    private var contentStackView: MobileContentStackView?
    private var callToActionView: ToolPageCallToActionView?
    private var cards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var currentCardState: ToolPageCardsState = .initialized
    private var toolModal: ToolPageModalView?
    private var cardBounceAnimation: ToolPageCardBounceAnimation?
    private var bottomView: UIView?
    private var didLayoutSubviews: Bool = false
    
    private weak var windowViewController: UIViewController?
    
    @IBOutlet weak private var backgroundImageContainer: UIView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var headerTrainingTipView: UIView!
    @IBOutlet weak private var heroContainerView: UIView!
    @IBOutlet weak private var callToActionContainerView: UIView!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var headerTop: NSLayoutConstraint!
    @IBOutlet weak private var headerTrainingTipLeading: NSLayoutConstraint!
    @IBOutlet weak private var heroTop: NSLayoutConstraint!
    @IBOutlet weak private var heroHeight: NSLayoutConstraint!
    @IBOutlet weak private var callToActionBottom: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    required init(viewModel: ToolPageViewModelType, windowViewController: UIViewController, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.windowViewController = windowViewController
        self.safeArea = safeArea
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
                
        addGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
        panGestureToControlPageCollectionViewPanningSensitivity.delegate = self
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
    
    private func setupLayout() {
        
        // headerContainerView
        headerContainerView.isHidden = true
        headerContainerView.backgroundColor = .clear
        setHeaderHidden(hidden: true, animated: false)
        
        // headerTrainingTipView
        headerTrainingTipView.backgroundColor = .clear
        
        // heroContainerView
        heroContainerView.isHidden = true
        heroContainerView.backgroundColor = .clear
        
        // callToActionContainerView
        callToActionContainerView.isHidden = true
        callToActionContainerView.backgroundColor = .clear
        setCallToActionHidden(hidden: true, animated: false)
    }
    
    private func setupBinding() {
        
        topInsetTopConstraint.constant = safeArea.top
        bottomInsetBottomConstraint.constant = safeArea.bottom
        
        backgroundColor = viewModel.backgroundColor
        
        // backgroundImageView
        if let backgroundImageViewModel = viewModel.backgroundImageWillAppear() {
            backgroundImageView.configure(viewModel: backgroundImageViewModel, parentView: backgroundImageContainer)
        }
                
        // headerView
        if let headerViewModel = viewModel.headerWillAppear() {
            let headerView = ToolPageHeaderView(viewModel: headerViewModel)
            addHeaderView(headerView: headerView)
            headerContainerView.layoutIfNeeded()
            headerTrainingTipLeading.constant = headerView.titleLabelFrame.origin.x - (headerTrainingTipView.frame.size.width / 2) + 5
            layoutIfNeeded()
        }
        
        // headerTrainingTipView
        viewModel.hidesHeaderTrainingTip.addObserver(self) { [weak self] (hidesHeaderTrainingTip: Bool) in
            self?.headerTrainingTipView.isHidden = hidesHeaderTrainingTip
        }
        
        if let headerTrainingTipViewModel = viewModel.headerTrainingTipViewModel {
            
            let trainingTipView = TrainingTipView(
                viewModel: headerTrainingTipViewModel
            )
            
            headerTrainingTipView.addSubview(trainingTipView)
            trainingTipView.constrainEdgesToSuperview()
        }
        
        // heroView
        if let heroViewModel = viewModel.heroWillAppear() {
            addHeroView(heroView: ToolPageHeroView(viewModel: heroViewModel))
        }
        
        // callToActionView
        if let callToActionViewModel = viewModel.callToActionWillAppear() {
            addCallToActionView(callToActionView: ToolPageCallToActionView(viewModel: callToActionViewModel))
        }
                    
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
            self?.handleKeyboardStateChange(keyboardStateChange: keyboardStateChange)
        }
        
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
                        
        //cards
        if viewModel.numberOfCards > 0 {
                        
            addCardsAndCardsConstraints(parentView: self, cardsViewModels: viewModel.cardsViewModels)
                        
            setCardsState(cardsState: .starting, animated: false)
            
            viewModel.currentCard.addObserver(self) { [weak self] (cardPositionAnimatable: AnimatableValue<Int?>) in
                self?.setCardsState(cardsState: .showingCard(showingCardAtPosition: cardPositionAnimatable.value), animated: cardPositionAnimatable.animated)
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
        
        addBottomView()
        
        updateHeroPosition()
    }
    
    func pageDidAppear() {
        
    }
    
    func pageDidDisappear() {
        
    }
    
    private var numberOfCards: Int {
        return viewModel.numberOfCards
    }
    
    // MARK: - Header
    
    private func addHeaderView(headerView: ToolPageHeaderView) {
        
        guard self.headerView == nil else {
            return
        }
        
        headerContainerView.isHidden = false
        headerContainerView.addSubview(headerView)
        headerView.constrainEdgesToSuperview()
        self.headerView = headerView
        
        setHeaderHidden(hidden: false, animated: false)
    }
    
    private func setHeaderHidden(hidden: Bool, animated: Bool) {
         
        let headerShouldBeHidden: Bool = headerView?.viewModel.hidesHeader ?? true
                
        let attemptingToShowHeader: Bool = !hidden
        if attemptingToShowHeader && headerShouldBeHidden {
            return
        }
        
        let topConstant: CGFloat = hidden ? headerContainerView.frame.size.height * -1 : 0
        let headerAlpha: CGFloat = hidden ? 0 : 1
        
        headerTop.constant = topConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
                self.headerContainerView.alpha = headerAlpha
                self.headerTrainingTipView.alpha = headerAlpha
            }, completion: nil)
        }
        else {
            layoutIfNeeded()
            headerContainerView.alpha = headerAlpha
            headerTrainingTipView.alpha = headerAlpha
        }
    }
    
    // MARK: - Hero
    
    private func addHeroView(heroView: ToolPageHeroView) {
        
        guard self.heroView == nil else {
            return
        }
        
        heroContainerView.isHidden = false
        heroContainerView.addSubview(heroView)
        heroView.constrainEdgesToSuperview()
        self.heroView = heroView
    }
    
    private func updateHeroPosition() {
        
        if self.heroView == nil {
            return
        }
        
        let hidesCards: Bool = viewModel.numberOfVisibleCards == 0
        let hidesCallToAction: Bool = callToActionView?.viewModel.hidesCallToAction ?? true
        
        let topInset: CGFloat = 15
        let bottomInset: CGFloat = 0
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        let headerHeight: CGFloat = headerContainerView.isHidden ? 0 : headerContainerView.frame.size.height
        let maximumHeight: CGFloat = screenHeight - safeArea.top - safeArea.bottom - headerHeight - topInset - bottomInset
                
        if hidesCards && hidesCallToAction {
            heroHeight.constant = maximumHeight
        }
        else if hidesCards && !hidesCallToAction {
            heroHeight.constant = maximumHeight - callToActionContainerView.frame.size.height
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
        layoutIfNeeded()
    }
    
    // MARK: - Call To Action
    
    private func addCallToActionView(callToActionView: ToolPageCallToActionView) {
        
        guard self.callToActionView == nil else {
            return
        }
        
        callToActionView.configure(delegate: self)
        
        callToActionContainerView.isHidden = false
        callToActionContainerView.addSubview(callToActionView)
        callToActionView.constrainEdgesToSuperview()
        self.callToActionView = callToActionView
        
        callToActionContainerView.layoutIfNeeded()
        
        setCallToActionHidden(hidden: false, animated: false)
    }
    
    private func setCallToActionHidden(hidden: Bool, animated: Bool) {
        
        let callToActionShouldBeHidden: Bool = callToActionView?.viewModel.hidesCallToAction ?? true
        
        let attemptingToShowCallToAction: Bool = !hidden
        if attemptingToShowCallToAction && callToActionShouldBeHidden {
            return
        }
        
        let bottomConstant: CGFloat = hidden ? callToActionContainerView.frame.size.height : 0
        let callToActionAlpha: CGFloat = hidden ? 0 : 1
        
        callToActionBottom.constant = bottomConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.layoutIfNeeded()
                self.callToActionContainerView.alpha = callToActionAlpha
            }, completion: nil)
        }
        else {
            layoutIfNeeded()
            callToActionContainerView.alpha = callToActionAlpha
        }
    }
}

// MARK: - MobileContentRenderableView

extension ToolPageView: MobileContentRenderableView {
    
    var view: UIView {
        return self
    }
    
    func addRenderableView(renderableView: MobileContentRenderableView) {
        
    }
    
    func finishedRenderingChildren() {
        
    }
    
    func viewDidAppear() {
        heroView?.viewDidAppear()
    }
    
    func viewDidDisappear() {
        heroView?.viewDidDisappear()
    }
}

// MARK: - ToolPageCardBounceAnimationDelegate

extension ToolPageView: ToolPageCardBounceAnimationDelegate {
    func toolPageCardBounceAnimationDidFinish(cardBounceAnimation: ToolPageCardBounceAnimation, forceStopped: Bool) {
        viewModel.cardBounceAnimationFinished()
    }
}

// MARK: - ToolPageCallToActionViewDelegate

extension ToolPageView: ToolPageCallToActionViewDelegate {
    func callToActionNextButtonTapped() {
        viewModel.callToActionNextButtonTapped()
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
               
        let callToActionHeight: CGFloat = callToActionContainerView.frame.size.height
        
        guard let cardView = cards.first else {
            assertionFailure("Cards should be initialized before cardHeight is accessed.")
            return cardsContainerHeight - callToActionHeight - cardInsets.top - cardInsets.bottom
        }
                
        let numberOfVisibleCards: CGFloat = CGFloat(viewModel.numberOfVisibleCards)
        let cardTitleHeight: CGFloat = cardView.cardHeaderHeight
        let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
        let collapsedCardsHeight: CGFloat = (cardTopVisibilityHeight * (numberOfVisibleCards - 1))
                
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
        
        let numberOfVisibleCards: CGFloat = CGFloat(viewModel.numberOfVisibleCards)
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
    
    private func setCardsState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            setHeaderHidden(hidden: false, animated: animated)
            setCallToActionHidden(hidden: true, animated: animated)
            
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
                setCardsState(cardsState: .collapseAllCards, animated: animated)
                return
            }
            
            setHeaderHidden(hidden: true, animated: animated)
            
            let isShowingLastVisibleCard: Bool = showCardAtPosition >= viewModel.numberOfVisibleCards - 1
            
            setCallToActionHidden(hidden: !isShowingLastVisibleCard, animated: animated)
            
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
    
    private func addCardsAndCardsConstraints(parentView: UIView, cardsViewModels: [ToolPageCardViewModelType]) {
        
        for cardViewModel in cardsViewModels {
            
            instatiateAndAddNewCard(parentView: parentView, cardViewModel: cardViewModel)
        }
    }
    
    private func instatiateAndAddNewCard(parentView: UIView, cardViewModel: ToolPageCardViewModelType) {
        
        let cardView: ToolPageCardView = ToolPageCardView(viewModel: cardViewModel)
                
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
    }
}

// MARK: - Keyboard
extension ToolPageView {
    
    func handleKeyboardStateChange(keyboardStateChange: KeyboardStateChange) {
        
        guard let currentCardPosition = viewModel.currentCard.value.value else {
            return
        }
        
        guard currentCardPosition >= 0 && currentCardPosition < numberOfCards else {
            return
        }
        
        switch keyboardStateChange.keyboardState {

        case .willShow:
            setCardsState(cardsState: .showingKeyboard(showingCardAtPosition: currentCardPosition), animated: true)
        case .willHide:
            setCardsState(cardsState: .showingCard(showingCardAtPosition: currentCardPosition), animated: true)
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

// MARK: - BottomView

extension ToolPageView {
    
    func addBottomView() {
        
        guard safeArea.bottom > 0 else {
            return
        }
        
        if let bottomView = self.bottomView {
            bottomView.removeFromSuperview()
            self.bottomView = nil
        }
        
        let bottomView = UIView()
        self.bottomView = bottomView
        bottomView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: safeArea.bottom)
        addSubview(bottomView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
                
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: bottomView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: bottomView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0
        )
        
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: bottomView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(leading)
        addConstraint(trailing)
        addConstraint(bottom)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: bottomView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: safeArea.bottom
        )
        
        bottomView.addConstraint(heightConstraint)
        
        bottomView.layoutIfNeeded()
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        bottomView.addSubview(blurEffectView)
        bottomView.backgroundColor = viewModel.bottomViewColor
        blurEffectView.frame = bottomView.bounds
    }
}
