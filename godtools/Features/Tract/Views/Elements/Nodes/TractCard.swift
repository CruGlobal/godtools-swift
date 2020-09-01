//
//  TractCard.swift
//  godtools
//
//  Created by Devserker on 4/28/17.
//  Copyright © 2017 Cru. All rights reserved.
//

import UIKit

class TractCard: BaseTractElement {
    
    enum CardAnimationState {
        case show, hide, none
    }
    
    // MARK: Positions constants
    
    static let xMarginConstant: CGFloat = 12.0
    static let shadowPaddingConstant: CGFloat = 2.0
    static let yTopMarginConstant: CGFloat = 8.0
    static let yBottomMarginConstant: CGFloat = 120.0
    static let xPaddingConstant: CGFloat = 28.0
    static let contentBottomPadding: CGFloat = 8.0
    static let transparentViewHeight: CGFloat = 60.0
    static let keyboardYTransformation: CGFloat = -80.0
    let footerViewHeight: CGFloat = 44.0

    // MARK: - Positions and Sizes
    
    var yDownPosition: CGFloat = 0.0
    
    var externalHeight: CGFloat {
        return (self.parent?.height)! - TractCard.yTopMarginConstant - TractCard.yBottomMarginConstant - TractPage.navbarHeight
    }
    
    var internalHeight: CGFloat {
        if self.height > self.externalHeight {
            return self.height + TractCard.transparentViewHeight + TractCard.contentBottomPadding
        } else {
            return self.externalHeight
        }
    }
    
    var translationY: CGFloat {
        return self.externalHeight - self.elementFrame.y
    }
    
    // MARK: - Object properties
    
    private let shouldDecreaseTractCollectionViewPanningSensitivity: Bool = true
    
    private var panGestureToControlTractCollectionViewPanningSensitivity: UIPanGestureRecognizer?
    
    var shadowView = UIView()
    let scrollView = UIScrollView()
    let backgroundView = UIView()
    let containerView = UIView()
    var cardsParentView: TractCards {
        return self.parent as! TractCards
    }
    var currentAnimation: TractCard.CardAnimationState = .none
    
    private func getAnimationPosition(position: TractCard.CardAnimationState) -> CGFloat {
        
        switch position {
        case .show:
            return TractCard.yTopMarginConstant - elementFrame.y
        case .hide:
            return yDownPosition
        case .none:
            return 0
        }
    }
    
    var tractCardAnalyticEvents: [TractAnalyticEvent]  {
            return self.analyticsUserInfo
    }
    
    // MARK: - Setup
    
    override func reset() {
        super.reset()
        
        let properties = cardProperties()
        
        if properties.cardState == .preview {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStatePreview()
        }
        
        hideTexts()
        resetCardToOriginalPositionAnimation()
        disableScrollview()
    }
    
    override func propertiesKind() -> TractProperties.Type {
        return TractCardProperties.self
    }
    
    override func loadStyles() {
        let properties = cardProperties()
        
        if properties.hidden {
            self.isHidden = true
            properties.cardState = .hidden
        }
    }
    
    override func render() -> UIView {
        setupScrollView()
        setBordersAndShadows()
        disableScrollview()
        setupSwipeGestures()
        
        for element in self.elements! {
            self.containerView.addSubview(element.render())
        }
        
        self.scrollView.addSubview(self.containerView)
        self.addSubview(self.shadowView)
        self.addSubview(self.backgroundView)
        self.addSubview(self.scrollView)

        hideTexts()
        setupTransparentView()
        setupBackground()
        loadParallelElementState()
        let pageCount = cardsParentView.splitCardsByKind().normal.count
        if cardProperties().cardState != .hidden {
            setupNavigation(pageNumber: cardProperties().cardNumber + 1, pageCount: pageCount)
        }
        TractBindings.addBindings(self)
        return self
    }
    
    override func elementListeners() -> [String]? {
        let properties = cardProperties()
        return properties.listeners == "" ? nil : properties.listeners.components(separatedBy: " ")
    }
    
    override func elementDismissListeners() -> [String]? {
        let properties = cardProperties()
        return properties.dismissListeners == "" ? nil : properties.dismissListeners.components(separatedBy: " ")
    }
    
    override func loadFrameProperties() {
        self.elementFrame.x = 0
        self.elementFrame.width = self.parentWidth()
        self.elementFrame.xMargin = TractCard.xMarginConstant
    }
    
    override func updateFrameHeight() {
        self.elementFrame.height = cardHeight()
        self.frame = self.elementFrame.getFrame()
    }
    
    override func loadParallelElementState() {
        guard let element = self.parallelElement else {
            return
        }
        
        let cardElement = element as! TractCard
        self.isHidden = cardElement.isHidden
        self.currentAnimation = cardElement.currentAnimation
        self.scrollView.isScrollEnabled = cardElement.scrollView.isScrollEnabled
        
        let currentProperties = cardElement.cardProperties()
        let properties = self.cardProperties()
        properties.cardState = currentProperties.cardState
        
        switch cardElement.currentAnimation {
        case .show:
            self.cardsParentView.lastCardOpened = self
            setPositionToShowCard(animated: false)
            showTexts()
            showCallToAction()
        case .hide:
            setPositionToHideCard(animated: false)
        default:
            break
        }
    }
    
    private func showCallToAction() {
        if cardsParentView.lastCard == self {
            cardsParentView.showCallToAction(animated: false)
        }
    }
    
    override func viewDidAppearOnTract() {
                
        guard let cardsElement = self.parent as? TractCards else {
            return
        }
        
        if self == cardsElement.elements?.first {
            loadFirstTimeAccessAnimation()
        }
    }
    
    // MARK: - Helpers
    
    func cardProperties() -> TractCardProperties {
        return self.properties as! TractCardProperties
    }
    
    func cardHeight() -> CGFloat {
        return self.getMaxHeight() - TractCard.yBottomMarginConstant - TractPage.navbarHeight - TractPage.statusbarHeight - TractPageContainer.marginBottom
    }
    
    func endCardEditing() {
        self.endEditing(true)
    }
    
    func loadFirstTimeAccessAnimation() {
        
        let isNewUser: Bool = dependencyContainer.isNewUserService.determineNewUser.isNewUser
        let didShowCardJump: Bool = dependencyContainer.cardJumpService.didShowCardJump
        
        if isNewUser && !didShowCardJump {
            dependencyContainer.cardJumpService.saveDidShowCardJump()
            openingAnimation()
        }
    }
}

// MARK: - Actions

extension TractCard {
    
    override func receiveMessage() {
        if isHiddenKindCard() {
            showCard(animated: true)
        }
    }
    
    override func receiveDismissMessage() {
        hideCard(animated: true)
    }
    
    func processSwipeUp(animated: Bool) {
        
        let properties = cardProperties()
        if properties.cardState == .preview || properties.cardState == .close {
            showCardAndPreviousCards(animated: animated)
        } else if properties.cardState == .open {
            self.cardsParentView.showFollowingCardToCard(self)
            
            // Need to adjust the Card number/letterName for proper analytics tracking
            let adjustedLetterName = (properties.cardNumber + 1).convertToLetter()
            let relay = AnalyticsRelay.shared
            if relay.tractCardCurrentLetterNames.contains(adjustedLetterName) {
                processCardForAnalytics(cardLetterName: adjustedLetterName)
            }
        }
        NotificationCenter.default.post(name: .tractCardStateChangedNotification, object: nil, userInfo: nil)
    }
    
    func processSwipeDown(animated: Bool) {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .enable {
            
            hideCard(animated: animated)
            
            // Need to adjust the Card number/letterName for proper analytics tracking
            let adjustedLetterName = (properties.cardNumber - 1).convertToLetter()
            let relay = AnalyticsRelay.shared
            if relay.tractCardCurrentLetterNames.contains(adjustedLetterName) {
                processCardForAnalytics(cardLetterName: adjustedLetterName)
            }
        }
        NotificationCenter.default.post(name: .tractCardStateChangedNotification, object: nil, userInfo: nil)
    }
    
    func processCardWithState() {
        let properties = cardProperties()
        
        switch properties.cardState {
        case .preview:
            showCardAndPreviousCards(animated: true)
        case .open:
            hideAllCards()
        case .close:
            showCardAndPreviousCards(animated: true)
        case .enable:
            hideCard(animated: true)
        default: break
        }
    }
    
    func showCardAndPreviousCards(animated: Bool) {
        let properties = cardProperties()
        
        if properties.cardState == .open {
            return
        }
        NotificationCenter.default.post(name: .tractCardStateChangedNotification, object: nil, userInfo: nil)

        self.cardsParentView.setEnvironmentForDisplayingCard(self)
        showCard(animated: animated)
        processCardForAnalytics(cardLetterName: properties.cardLetterName)
    }
    
    func showCard(animated: Bool) {
        let properties = cardProperties()
        if properties.cardState == .open {
            return
        }
        
        if isHiddenKindCard() {
            setStateEnable()
        } else {
            setStateOpen()
        }
        
        showTexts()
        setPositionToShowCard(animated: animated)
        enableScrollview()
        
        self.cardsParentView.lastCardOpened = self
    }
    
    func hideCard(animated: Bool) {
        let properties = cardProperties()
        
        if properties.cardState == .close || properties.cardState == .hidden {
            return
        }
        
        if isHiddenKindCard() {
            setStateHidden()
        } else {
            setStateClose()
        }
        
        hideTexts()
        self.cardsParentView.hideCallToAction()
        setPositionToHideCard(animated: animated)
        disableScrollview()

    }
    
    func hideAllCards() {
        let properties = cardProperties()
        
        if properties.cardState == .close || properties.cardState == .hidden {
            return
        }
        
        hideTexts()
        self.cardsParentView.reset()
        self.cardsParentView.hideCallToAction()

    }

    func showTexts() {
        for element in self.elements! {
            if BaseTractElement.isLabelElement(element) {
                continue
            }
            
            element.isHidden = false
        }
    }
    
    func hideTexts() {
        for element in self.elements! {
            if BaseTractElement.isLabelElement(element) {
                continue
            }
            
            element.isHidden = true
        }
    }
    
    // MARK: - ScrollView
    
    func disableScrollview() {
        let properties = cardProperties()
        
        if properties.cardState != .open && properties.cardState != .enable {
            let startPoint = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
            self.scrollView.isScrollEnabled = false
            self.scrollView.setContentOffset(startPoint, animated: true)
        }
    }
    
    func enableScrollview() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .enable {
            self.scrollView.isScrollEnabled = true
        }
    }
    
    // MARK: - Management of card state
    
    fileprivate func isHiddenKindCard() -> Bool {
        let properties = cardProperties()
        
        return properties.cardState == .hidden || properties.cardState == .enable
    }
    
    fileprivate func setStateOpen() {
        let properties = cardProperties()
        
        if properties.cardState == .preview || properties.cardState == .close {
            properties.cardState = .open
        }
    }
    
    fileprivate func setStateClose() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .preview {
            properties.cardState = .close
        }
    }
    
    fileprivate func setStateHidden() {
        let properties = cardProperties()
        
        if properties.cardState == .enable {
            properties.cardState = .hidden
        }
    }
    
    fileprivate func setStateEnable() {
        let properties = cardProperties()
        
        if properties.cardState == .hidden {
            self.isHidden = false
            properties.cardState = .enable
        }
    }
    
    fileprivate func setStatePreview() {
        let properties = cardProperties()
        
        if properties.cardState == .open || properties.cardState == .close {
            properties.cardState = .preview
        }
    }
    
    // MARK - Analytics helper
    
    func processCardForAnalytics(cardLetterName: String) {
        let properties = cardProperties()
        let relay = AnalyticsRelay.shared
        relay.task.cancel()
        
        // MARK - Get the analytics as a TractAnalyticEvent.
        
        let analyticEvents = properties.analyticEventProperties
        for analyticEvent in analyticEvents {
            if analyticEvent.delay != "" {
                let delayDouble = Double(analyticEvent.delay) ?? 0
                relay.createDelayedTask(delayDouble, with: TractAnalyticEvent.convertToDictionary(from: analyticEvent))
            }
        }
        
        relay.screenNamePlusCardLetterName = relay.screenName + cardLetterName
        screenViewNotification(screenName: relay.screenName + cardLetterName)
    }
    
    func screenViewNotification(screenName: String) {
        
        let userInfo = [GTConstants.kAnalyticsScreenNameKey: screenName]
        NotificationCenter.default.post(name: .screenViewNotification,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        processSwipeDown(animated: true)
    }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        processSwipeUp(animated: true)
    }
}

// MARK: - Animations

extension TractCard {
    
    static let bounceDecayFactor: CGFloat = 0.2
    static let bounceCycles = 3
    static let numberOfBounces = 2
    static let secondsBetweenCycles: Double = 0.6
    static let bounceDuration: Double = 0.15
    
    func openingAnimation(yTransformation: CGFloat = -50.0, delay: Double = 0.0, cycleNumber: Int = 1, bounceNumber: Int = 1 ) {
        UIView.animate(withDuration: TractCard.bounceDuration,
                       delay: delay,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: { finished in
                        self.closingAnimation(cycleNumber: cycleNumber,
                                              bounceNumber: bounceNumber,
                                              yOpeningTransformation: yTransformation)
        } )
    }
    
    func closingAnimation(cycleNumber: Int, bounceNumber: Int, yOpeningTransformation: CGFloat) {
        let yTransformation: CGFloat = 0.0
        UIView.animate(withDuration: TractCard.bounceDuration,
                       delay: 0.1,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yTransformation) },
                       completion: { finished in
                        
                        if bounceNumber < TractCard.numberOfBounces {
                            self.openingAnimation(yTransformation: yOpeningTransformation * TractCard.bounceDecayFactor,
                                                  delay: 0.1,
                                                  cycleNumber: cycleNumber,
                                                  bounceNumber: bounceNumber + 1)
                        } else if cycleNumber < TractCard.bounceCycles {
                            self.openingAnimation(delay: TractCard.secondsBetweenCycles,
                                                  cycleNumber: cycleNumber + 1)
                        }
                        
        })
    }
    
    private func setPositionToShowCard(animated: Bool) {
                
        self.currentAnimation = .show
        
        let yPosition: CGFloat = getAnimationPosition(position: .show)
        
        if animated {
            UIView.animate(withDuration: 0.35,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
             self.transform = CGAffineTransform(translationX: 0, y: yPosition) },
            completion: nil)
        }
        else {
            transform = CGAffineTransform(translationX: 0, y: yPosition)
        }
    }
    
    private func setPositionToHideCard(animated: Bool) {
        
        self.currentAnimation = .hide
        
        let yPosition: CGFloat = getAnimationPosition(position: .hide)
        
        if animated {
            UIView.animate(withDuration: 0.45,
            delay: 0.0,
            options: UIView.AnimationOptions.curveEaseInOut,
            animations: {
             self.transform = CGAffineTransform(translationX: 0, y: yPosition) },
            completion: { (completed) in
             if completed {
                self.handleSetPositionToHideCompleted()
             }})
        }
        else {
            transform = CGAffineTransform(translationX: 0, y: yPosition)
            handleSetPositionToHideCompleted()
        }
    }
    
    private func handleSetPositionToHideCompleted() {
        
        let properties = cardProperties()
        
        if properties.cardNumber == 0 {
            cardsParentView.reset()
        }
        
        if properties.cardState == .hidden {
            isHidden = true
        }
    }
    
    func resetCardToOriginalPositionWithoutAnimation() {
        self.currentAnimation = .none
        let yPosition: CGFloat = getAnimationPosition(position: .none)
        self.transform = CGAffineTransform(translationX: 0, y: yPosition)
    }
    
    func resetCardToOriginalPositionAnimation() {
        self.currentAnimation = .none
        let yPosition: CGFloat = getAnimationPosition(position: .none)
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: 0, y: yPosition) },
                       completion: nil )
    }
    
    func moveViewForPresentingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: TractCard.keyboardYTransformation) },
                       completion: nil )
    }
    
    func moveViewForDismissingKeyboardAnimation() {
        UIView.animate(withDuration: 0.35,
                       delay: 0.0,
                       options: UIView.AnimationOptions.curveEaseInOut,
                       animations: {
                        self.containerView.transform = CGAffineTransform(translationX: 0, y: 0) },
                       completion: nil )
    }
    
}

// MARK: - Gestures

extension TractCard: UIGestureRecognizerDelegate {
    
    func setupSwipeGestures() {
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeUp.direction = .up
        addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleGesture))
        swipeDown.direction = .down
        addGestureRecognizer(swipeDown)
        
        if shouldDecreaseTractCollectionViewPanningSensitivity {
            let panGesture = UIPanGestureRecognizer()
            panGesture.delegate = self
            addGestureRecognizer(panGesture)
            self.panGestureToControlTractCollectionViewPanningSensitivity = panGesture
        }
    }
    
    @objc func handleGesture(sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            processSwipeUp(animated: true)
        } else if sender.direction == .down {
            processSwipeDown(animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let panGesture = self.panGestureToControlTractCollectionViewPanningSensitivity, gestureRecognizer == panGesture {
                        
            if let otherView = otherGestureRecognizer.view, otherView is UICollectionView, let tractPanGesture = otherGestureRecognizer as? UIPanGestureRecognizer {
                
                let velocity: CGPoint = tractPanGesture.velocity(in: self)
                        
                let angleRadians: CGFloat = atan2(velocity.y, velocity.x)
                var angleDegrees: CGFloat = angleRadians * 57.2958
                if angleDegrees < 0 {
                    angleDegrees *= -1
                }
                let rightToLeftDegrees: CGFloat = 180
                let leftToRightDegrees: CGFloat = 0
                let allowedPanOffsetDegrees: CGFloat = 20
                                    
                let shouldRecognizeTractPanning: Bool
                
                if angleDegrees >= rightToLeftDegrees - allowedPanOffsetDegrees && angleDegrees <= rightToLeftDegrees + allowedPanOffsetDegrees {
                    shouldRecognizeTractPanning = true
                }
                else if angleDegrees >= leftToRightDegrees - allowedPanOffsetDegrees && angleDegrees <= leftToRightDegrees + allowedPanOffsetDegrees {
                    shouldRecognizeTractPanning = true
                }
                else {
                    shouldRecognizeTractPanning = false
                }
                
                return shouldRecognizeTractPanning
            }
            else {

                // Allow simultaneous gestures whenever the tract card pan gesture is active against any gesture that is not the tract collection view pan gesture.
                return true
            }
        }
        
        return false
    }
}

extension TractCard : UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: self.superview)
        let scrollOffset = scrollView.contentOffset.y
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        
        if translation.y > 0 {
            if scrollOffset == 0 {
                hideCard(animated: true)
            }
        } else {
            if scrollOffset + scrollViewHeight == scrollContentSizeHeight {
                self.cardsParentView.showFollowingCardToCard(self)
            }
        }
    }
}

// MARK: - UI

extension TractCard {
    
    func setupBackground() {
        let elementProperties = self.cardProperties()
        if elementProperties.backgroundImage == "" {
            return
        }
        
        guard let image = manifestProperties.getResourceForFile(filename: elementProperties.backgroundImage) else {
            return
        }
        
        let imageView = buildScaledImageView(parentView: self.backgroundView,
                                             image: image,
                                             aligns: elementProperties.backgroundImageAlign,
                                             scaleType: elementProperties.backgroundImageScaleType)
        
        self.backgroundView.addSubview(imageView)
        self.backgroundView.clipsToBounds = true
    }
    
    func setupTransparentView() {
        if self.externalHeight >= self.internalHeight {
            return
        }
        
        let width = self.scrollView.frame.size.width - 6.0
        let height: CGFloat = TractCard.transparentViewHeight
        let xPosition: CGFloat = 3.0
        let yPosition = self.scrollView.frame.size.height - height
        let transparentViewFrame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let transparentView = UIView(frame: transparentViewFrame)
        transparentView.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = transparentView.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.cgColor]
        transparentView.layer.insertSublayer(gradientLayer, at: 0)
        
        self.addSubview(transparentView)
    }
    
    func setupScrollView() {
        let width = self.elementFrame.finalWidth() - (TractCard.shadowPaddingConstant * CGFloat(2))
        let xPosition = (self.elementFrame.finalWidth() - width) / CGFloat(2)
        let height = self.bounds.size.height - 1.0 - footerViewHeight
        let scrollViewFrame = CGRect(x: xPosition, y: 0.0, width: width, height: height)
        
        self.scrollView.contentSize = CGSize(width: width, height: self.internalHeight)
        self.scrollView.frame = scrollViewFrame
        self.scrollView.delegate = self
        self.scrollView.backgroundColor = .clear
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.backgroundView.frame = scrollViewFrame
        
        self.containerView.frame = CGRect(x: 0.0,
                                          y: 0.0,
                                          width: width,
                                          height: self.internalHeight)
        self.containerView.backgroundColor = .clear
    }
    
    func setBordersAndShadows() {
        self.shadowView.frame = self.bounds
        self.shadowView.backgroundColor = cardBackgroundColor()
        let shadowLayer = self.shadowView.layer
        shadowLayer.cornerRadius = 8.0
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowRadius = 8.0
        shadowLayer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        shadowLayer.shadowOpacity = 0.4
        shadowLayer.shouldRasterize = true
    }
    
    func cardBackgroundColor() -> UIColor {
        let elementProperties = cardProperties()
        
        if let bgc = elementProperties.backgroundColor {
            return bgc
        }
        
        // Ugly! Pressuming composition
        if let pageElementProperty = self.parent?.parent?.parent?.properties as? TractPageProperties {
            if let bgc = pageElementProperty.cardBackgroundColor {
                return bgc
            }
        }
                
        let manifestProps = manifestProperties
        if let bgc = manifestProps.cardBackgroundColor {
            return bgc
        }
        
        return manifestProps.backgroundColor
    }
        
    func setupNavigation(pageNumber: Int, pageCount: Int) {
        
        let language = tractConfigurations?.language?.code
        
        let prevButton =  UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
        prevButton.setTitle("card_status1".localized(for: language), for: .normal)
        prevButton.setTitleColor(.gray, for: .normal)
        prevButton.titleLabel?.textAlignment = .right
        prevButton.addTarget(self, action: #selector(prevButtonTapped(_:)), for: .touchUpInside)
        let nextButton = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
        let nextButtonTitle = pageNumber == pageCount ? "" : "card_status2".localized(for: language)
        nextButton.setTitle(nextButtonTitle, for: .normal)
        nextButton.setTitleColor(.gray, for: .normal)
        nextButton.titleLabel?.textAlignment = .left
        nextButton.isEnabled = !(pageNumber == pageCount)
        nextButton.addTarget(self, action: #selector(nextButtonTapped(_:)), for: .touchUpInside)
        let pageCountLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        pageCountLabel.text = "\(pageNumber) / \(pageCount)"
        pageCountLabel.textAlignment = .center
        pageCountLabel.textColor = .gray

        let stackViewWidth: CGFloat = 350
        let stackViewX = frame.size.width/2 - stackViewWidth/2
        let stackViewFrame = CGRect(x: stackViewX, y: frame.size.height-40.0, width: stackViewWidth, height: footerViewHeight)
        let stackView = UIStackView(arrangedSubviews: [prevButton, pageCountLabel, nextButton])
        stackView.semanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
        stackView.frame = stackViewFrame
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10.0
        addSubview(stackView)
    }
}

// MARK: - UITextFieldDelegate

extension TractCard: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveViewForPresentingKeyboardAnimation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            moveViewForDismissingKeyboardAnimation()
            endCardEditing()
            return true
        } else {
            let tractInput = textField.superview as! TractInput
            if let form = BaseTractElement.getFormForElement(tractInput) {
                if let followingTractInput = form.getFollowingInputForInput(element: tractInput) {
                    followingTractInput.textField.becomeFirstResponder()
                }
            }
            
            return false
        }
    }
}
