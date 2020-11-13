//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageView: UIViewController {
    
    private let viewModel: ToolPageViewModelType
    private let windowViewController: UIViewController
    private let safeAreaInsets: UIEdgeInsets
    private let panGestureToControlPageCollectionViewPanningSensitivity: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var contentStackView: ToolPageContentStackView?
    private var heroView: ToolPageContentStackView?
    private var cards: [ToolPageCardView] = Array()
    private var cardTopConstraints: [NSLayoutConstraint] = Array()
    private var hiddenCard: ToolPageCardView?
    private var hiddenCardTopConstraint: NSLayoutConstraint?
    private var currentCardState: ToolPageCardsState = .initialized
    private var toolModal: ToolPageModalView?
    private var didLayoutSubviews: Bool = false
    
    @IBOutlet weak private var backgroundImageView: UIImageView!
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerView: UIView!
    @IBOutlet weak private var headerNumberLabel: UILabel!
    @IBOutlet weak private var headerTitleLabel: UILabel!
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
    
    required init(viewModel: ToolPageViewModelType, windowViewController: UIViewController, safeAreaInsets: UIEdgeInsets) {
        self.viewModel = viewModel
        self.windowViewController = windowViewController
        self.safeAreaInsets = safeAreaInsets
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
        
        view.addGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
        panGestureToControlPageCollectionViewPanningSensitivity.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !didLayoutSubviews else {
            return
        }
        didLayoutSubviews = true
        
        let hidesHeader: Bool = viewModel.headerViewModel.hidesHeader
        let hidesCards: Bool = viewModel.cardsViewModels.isEmpty
        let hidesCallToAction: Bool = viewModel.callToActionViewModel.hidesCallToAction
        
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
        
        setHeaderHidden(hidden: hidesHeader, animated: false)
        setCallToActionHidden(hidden: hidesCallToAction, animated: false)
                
        //cards
        if !viewModel.cardsViewModels.isEmpty {
                        
            addCardsAndCardsConstraints(cardsViewModels: viewModel.cardsViewModels)
            
            view.layoutIfNeeded()
            
            setCardsState(cardsState: .starting, animated: false)
            
            viewModel.currentCard.addObserver(self) { [weak self] (cardPositionAnimatable: AnimatableValue<Int?>) in
                self?.setCardsState(cardsState: .showingCard(showingCardAtPosition: cardPositionAnimatable.value), animated: cardPositionAnimatable.animated)
            }
        }
        
        // hiddenCard
        viewModel.hiddenCard.addObserver(self) { [weak self] (hiddenCardAnimatable: AnimatableValue<Int?>) in
            if let cardPosition = hiddenCardAnimatable.value, let cardViewModel = self?.viewModel.hiddenCardWillAppear(cardPosition: cardPosition) {
                self?.showHiddenCard(cardViewModel: cardViewModel, animated: hiddenCardAnimatable.animated)
            }
            else {
                self?.hideHiddenCard(animated: hiddenCardAnimatable.animated)
            }
        }
        
        // hero top and height
        if let heroViewModel = viewModel.heroViewModel {
            
            let topInset: CGFloat = 15
            let bottomInset: CGFloat = 0
            let screenHeight: CGFloat = UIScreen.main.bounds.size.height
            let headerHeight: CGFloat = hidesHeader ? 0 : headerView.frame.size.height
            let maximumHeight: CGFloat = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom - headerHeight - topInset - bottomInset
            
            if hidesCards && hidesCallToAction {
                heroHeight.constant = maximumHeight
            }
            else if hidesCards && !hidesCallToAction {
                heroHeight.constant = maximumHeight - callToActionView.frame.size.height
            }
            else if !hidesCards {
                let cardCount: CGFloat =  CGFloat(viewModel.cardsViewModels.count)
                let cardTitleHeight: CGFloat = cards.first?.titleHeight ?? 50
                heroHeight.constant = maximumHeight - (cardCount * cardTitleHeight)
            }
                         
            heroTop.constant = headerHeight + topInset
                                    
            let heroView: ToolPageContentStackView = ToolPageContentStackView(viewModel: heroViewModel)
            heroContainerView.addSubview(heroView)
            heroView.constrainEdgesToSuperview()
            heroContainerView.isHidden = false
            self.heroView = heroView
            
            heroContainerView.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        else {
            heroContainerView.isHidden = true
        }
    }
    
    private func setupLayout() {
        
        topInsetTopConstraint.constant = safeAreaInsets.top
        bottomInsetBottomConstraint.constant = safeAreaInsets.bottom
    }
    
    private func setupBinding() {
        
        view.backgroundColor = viewModel.backgroundColor
        
        // backgroundImageView
        backgroundImageView.image = viewModel.backgroundImage
        backgroundImageView.isHidden = viewModel.backgroundImage == nil
        
        // headerView
        let headerViewModel: ToolPageHeaderViewModel = viewModel.headerViewModel
        headerView.backgroundColor = headerViewModel.backgroundColor
        headerNumberLabel.font = headerViewModel.headerNumberFont
        headerNumberLabel.text = headerViewModel.headerNumber
        headerNumberLabel.textColor = headerViewModel.headerNumberColor
        headerTitleLabel.font = headerViewModel.headerTitleFont
        headerTitleLabel.text = headerViewModel.headerTitle
        headerTitleLabel.textColor = headerViewModel.headerTitleColor
        headerTitleLabel.setLineSpacing(lineSpacing: 2)
                
        // callToAction
        let callToActionViewModel: ToolPageCallToActionViewModel = viewModel.callToActionViewModel
        callToActionTitleLabel.text = callToActionViewModel.callToActionTitle
        callToActionTitleLabel.textColor = callToActionViewModel.callToActionTitleColor
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
    }
    
    func getCurrentPositions() -> ToolPageInitialPositions? {
        return viewModel.getCurrentPositions()
    }
    
    @objc func handleCallToActionNext(button: UIButton) {
        viewModel.handleCallToActionNextButtonTapped()
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
    
    private func setHeaderHidden(hidden: Bool, animated: Bool) {
            
        if viewModel.headerViewModel.hidesHeader && !hidden {
            return
        }
        
        let topConstant: CGFloat = hidden ? headerView.frame.size.height * -1 : 0
        let headerAlpha: CGFloat = hidden ? 0 : 1
        
        headerTop.constant = topConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.headerView.alpha = headerAlpha
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
            headerView.alpha = headerAlpha
        }
    }
    
    private func setCallToActionHidden(hidden: Bool, animated: Bool) {
        
        if viewModel.callToActionViewModel.hidesCallToAction && !hidden {
            return
        }
        
        let bottomConstant: CGFloat = hidden ? callToActionView.frame.size.height : 0
        let callToActionAlpha: CGFloat = hidden ? 0 : 1
        
        callToActionBottom.constant = bottomConstant
        
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                self.callToActionView.alpha = callToActionAlpha
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
            callToActionView.alpha = callToActionAlpha
        }
    }
}

// MARK: - Modal

extension ToolPageView {
    
    private func presentModal(viewModel: ToolPageModalViewModel, animated: Bool) {
        
        guard toolModal == nil else {
            return
        }
        
        let toolModal: ToolPageModalView = ToolPageModalView(viewModel: viewModel)
        
        windowViewController.view.addSubview(toolModal)
        toolModal.frame = windowViewController.view.bounds
                        
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
        let top: CGFloat = safeAreaInsets.top
        let height: CGFloat = screenSize.height - top - safeAreaInsets.bottom
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
                
        let numberOfCards: CGFloat = CGFloat(viewModel.cardsViewModels.count)
        let cardTitleHeight: CGFloat = cardView.titleHeight
        let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
        let collapsedCardsHeight: CGFloat = (cardTopVisibilityHeight * (numberOfCards - 1))
        
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
        
        let numberOfCards: CGFloat = CGFloat(viewModel.cardsViewModels.count)
        let cardTitleHeight: CGFloat = cardView.titleHeight
        
        switch state {
            
        case .starting(let cardPosition):
            return cardsTopRelativeToCardsContainerFrameBottom - (cardTitleHeight * (numberOfCards - CGFloat(cardPosition)))
        
        case .showing:
            return cardsContainerFrameRelativeToScreen.origin.y + cardInsets.top
        
        case .collapsed(let cardPosition):
            let cardTopVisibilityHeight: CGFloat = floor(cardTitleHeight * cardCollapsedVisibilityPercentage)
            return cardsTopRelativeToCardsContainerFrameBottom - (cardTopVisibilityHeight * (numberOfCards - CGFloat(cardPosition)))
        
        case .hidden:
            return cardsTopRelativeToCardsContainerFrameBottom
        }
    }
    
    private func setCardsState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            setHeaderHidden(hidden: false, animated: animated)
            setCallToActionHidden(hidden: true, animated: animated)
            
            for index in 0 ..< cardTopConstraints.count {
                let topConstraint: NSLayoutConstraint = cardTopConstraints[index]
                topConstraint.constant = getCardTopConstant(state: .starting(cardPosition: index))
            }
            
        case .showingCard(let showingCardAtPosition):
            
            if showingCardAtPosition == nil && currentCardState == .starting {
                return
            }
            
            guard let showCardAtPosition = showingCardAtPosition else {
                setCardsState(cardsState: .collapseAllCards, animated: animated)
                return
            }
            
            setHeaderHidden(hidden: true, animated: animated)
            
            let isShowingLastCard: Bool = showCardAtPosition >= cards.count - 1
            
            setCallToActionHidden(hidden: !isShowingLastCard, animated: animated)
            
            for index in 0 ..< cardTopConstraints.count {
                
                let topConstraint: NSLayoutConstraint = cardTopConstraints[index]
                let shouldShowCard: Bool = index <= showCardAtPosition
                
                if shouldShowCard {
                    topConstraint.constant = getCardTopConstant(state: .showing)
                }
                else {
                    topConstraint.constant = getCardTopConstant(state: .collapsed(cardPosition: index))
                }
            }
                        
        case .collapseAllCards:
            
            for index in 0 ..< cardTopConstraints.count {
                
                let topConstraint: NSLayoutConstraint = cardTopConstraints[index]
                topConstraint.constant = getCardTopConstant(state: .collapsed(cardPosition: index))
            }
            
        case .initialized:
            break
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
        
        currentCardState = cardsState
    }
    
    private func handleCompletedSetCardState(cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
        
        case .starting:
            break
            
        case .showingCard(let showingCardAtPosition):
            break
                        
        case .collapseAllCards:
            setCardsState(cardsState: .starting, animated: animated)
            
        case .initialized:
            break
        }
    }
    
    private func showHiddenCard(cardViewModel: ToolPageCardViewModelType, animated: Bool) {
        
        guard hiddenCard == nil else {
            return
        }
        
        let cardView: ToolPageCardView = ToolPageCardView(viewModel: cardViewModel)
        
        view.addSubview(cardView)
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .top,
            multiplier: 1,
            constant: cardInsets.top
        )
        
        let leading: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: view,
            attribute: .leading,
            multiplier: 1,
            constant: cardInsets.left
        )
        
        let trailing: NSLayoutConstraint = NSLayoutConstraint(
            item: cardView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: view,
            attribute: .trailing,
            multiplier: 1,
            constant: cardInsets.right * -1
        )
        
        view.addConstraint(top)
        view.addConstraint(leading)
        view.addConstraint(trailing)
        
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
        
        hiddenCard = cardView
        hiddenCardTopConstraint = top
        
        hiddenCardTopConstraint?.constant = getCardTopConstant(state: .hidden)
        view.layoutIfNeeded()
        
        hiddenCardTopConstraint?.constant = getCardTopConstant(state: .showing)
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else {
            view.layoutIfNeeded()
        }
    }
    
    private func hideHiddenCard(animated: Bool) {
        
        hiddenCardTopConstraint?.constant = getCardTopConstant(state: .hidden)
        
        if animated {
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (finished: Bool) in
                self.handleHiddenCardHidden()
            })
        }
        else {
            view.layoutIfNeeded()
            handleHiddenCardHidden()
        }
    }
    
    private func handleHiddenCardHidden() {
        hiddenCard?.removeFromSuperview()
        hiddenCard = nil
        hiddenCardTopConstraint = nil
    }
    
    private func addCardsAndCardsConstraints(cardsViewModels: [ToolPageCardViewModelType]) {
        
        for cardViewModel in cardsViewModels {
            
            let cardView: ToolPageCardView = ToolPageCardView(viewModel: cardViewModel)
            
            cards.append(cardView)
            
            view.addSubview(cardView)

            cardView.translatesAutoresizingMaskIntoConstraints = false
            
            let top: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .top,
                relatedBy: .equal,
                toItem: view,
                attribute: .top,
                multiplier: 1,
                constant: cardInsets.top
            )
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .leading,
                relatedBy: .equal,
                toItem: view,
                attribute: .leading,
                multiplier: 1,
                constant: cardInsets.left
            )
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: cardView,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: view,
                attribute: .trailing,
                multiplier: 1,
                constant: cardInsets.right * -1
            )
            
            view.addConstraint(top)
            view.addConstraint(leading)
            view.addConstraint(trailing)
            
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

// MARK: - UIGestureRecognizerDelegate

extension ToolPageView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                
        if gestureRecognizer == panGestureToControlPageCollectionViewPanningSensitivity {
                        
            if let otherView = otherGestureRecognizer.view, otherView is UICollectionView, let collectionViewPanGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
                
                let velocity: CGPoint = collectionViewPanGesture.velocity(in: view)
                        
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
                
                // Allow simultaneous gestures whenever the pan gesture is active against any gesture that is not a collectionview.
                return true
            }
        }
        
        return true
    }
}
