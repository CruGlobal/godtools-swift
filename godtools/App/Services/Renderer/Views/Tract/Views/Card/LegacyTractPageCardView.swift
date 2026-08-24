//
//  LegacyTractPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit
import GodToolsShared

@MainActor
protocol LegacyTractPageCardViewDelegate: AnyObject {
    
    func tractPageCardHeaderTapped(cardView: LegacyTractPageCardView)
    func tractPageCardPreviousTapped(cardView: LegacyTractPageCardView)
    func tractPageCardNextTapped(cardView: LegacyTractPageCardView)
    func tractPageCardDidSwipeCardUp(cardView: LegacyTractPageCardView)
    func tractPageCardDidSwipeCardDown(cardView: LegacyTractPageCardView)
}

class LegacyTractPageCardView: LegacyMobileContentView, NibBased {
        
    private let viewModel: TractPageCardViewModel
    private let backgroundImageView: LegacyMobileContentBackgroundImageView = LegacyMobileContentBackgroundImageView()
    private let swipeUpGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    private let swipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    private let bottomGradientLayer: CAGradientLayer = CAGradientLayer()
    private let contentStackView: LegacyMobileContentStackView
    
    private lazy var keyboardObserver: KeyboardNotificationObserver = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var backgroundImageParent: UIView?
    private var formView: LegacyMobileContentFormView?
    private var startingHeaderTrainingTipIconTrailing: CGFloat = 20
    private var didRenderFirstLabel: Bool = false
    private var keyboardHeightForAddedContentSize: Double?
    private var didAddKeyboardHeightToContentSize: Bool = false
    private var cardSwipingIsEnabled: Bool = false
    private var heightConstraint: NSLayoutConstraint?
    
    private weak var delegate: LegacyTractPageCardViewDelegate?
           
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var headerTrainingTipImageView: UIImageView!
    @IBOutlet weak private var titleSeparatorLine: UIView!
    @IBOutlet weak private var headerButton: UIButton!
    @IBOutlet weak private var cardBackgroundImageContainer: UIView!
    @IBOutlet weak private var contentStackContainer: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    @IBOutlet weak private var cardPositionLabel: UILabel!
    @IBOutlet weak private var previousButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    
    @IBOutlet weak private var headerTrainingTipTrailing: NSLayoutConstraint!
    
    init(viewModel: TractPageCardViewModel) {
                
        self.viewModel = viewModel
        self.contentStackView = LegacyMobileContentStackView(viewModel: viewModel, contentInsets: UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15), scrollIsEnabled: true)
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
                
        let rootNibView: UIView? = loadNib()
        rootNibView?.semanticContentAttribute = viewModel.languageDirectionSemanticContentAttribute
        setupLayout()
        setupBinding()
        
        headerButton.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        swipeUpGesture.addTarget(self, action: #selector(handleSwipeGesture(swipeGesture:)))
        swipeUpGesture.delegate = self
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        
        swipeDownGesture.addTarget(self, action: #selector(handleSwipeGesture(swipeGesture:)))
        swipeDownGesture.delegate = self
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
        
        setCardSwipingEnabled(enabled: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        if let backgroundImageParent = self.backgroundImageParent {
            backgroundImageView.removeParentBoundsChangeObserver(parentView: backgroundImageParent)
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        relayoutBottomGradient()
    }
    
    private func setupLayout() {
        
        backgroundColor = .white
        
        let cardCornerRadius: CGFloat = 8
        
        startingHeaderTrainingTipIconTrailing = headerTrainingTipTrailing.constant
        
        // contentStackView
        contentStackContainer.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: contentStackContainer)
        layoutIfNeeded()
        contentStackView.setScrollViewContentInset(contentInset: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottomGradientView.frame.size.height,
            right: 0
        ))
        contentStackView.setScrollViewDelegate(delegate: self)
        setParentAndAddChild(childView: contentStackView)
        
        // shadow
        layer.cornerRadius = cardCornerRadius
        drawShadow(shadowOffset: CGSize(width: 1.5, height: 1.5), shadowRadius: 6, shadowOpacity: 0.3)
        
        // background corner radius
        let rootView: UIView? = subviews.first
        rootView?.layer.cornerRadius = cardCornerRadius
        
        // bottom gradient
        bottomGradientView.isUserInteractionEnabled = false
        bottomGradientView.backgroundColor = .clear
        bottomGradientLayer.frame = bottomGradientView.bounds
        bottomGradientLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradientLayer, at: 0)
    }
    
    private func setupBinding() {
        
        if let backgroundImageViewModel = viewModel.backgroundImageWillAppear() {
            
            let backgroundImageParent: UIView = cardBackgroundImageContainer
            self.backgroundImageParent = backgroundImageParent
            backgroundImageView.configure(viewModel: backgroundImageViewModel, parentView: backgroundImageParent, insertBackgroundAtIndex: 0)
            backgroundImageView.addParentBoundsChangeObserver(parentView: backgroundImageParent)
        }
        
        titleLabel.text = viewModel.title
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleColor
        titleLabel.textAlignment = viewModel.titleAlignment
        
        setHeaderTrainingTipIconHidden(hidden: viewModel.hidesHeaderTrainingTip)
        
        cardPositionLabel.text = viewModel.cardPositionLabel
        cardPositionLabel.textColor = viewModel.cardPositionLabelTextColor
        cardPositionLabel.font = viewModel.cardPositionLabelFont
        cardPositionLabel.isHidden = viewModel.hidesCardPositionLabel
        
        previousButton.setTitleColor(viewModel.previousButtonTitleColor, for: .normal)
        previousButton.isHidden = viewModel.hidesPreviousButton

        nextButton.setTitleColor(viewModel.nextButtonTitleColor, for: .normal)
        nextButton.isHidden = viewModel.hidesNextButton

        previousButton.setTitle(viewModel.previousButtonTitle, for: .normal)
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
    }
    
    private func relayoutBottomGradient() {
        bottomGradientLayer.frame = bottomGradientView.bounds
    }
    
    private func searchChildForNestedForm(childView: LegacyMobileContentView) -> LegacyMobileContentFormView? {
        
        if let formView = childView as? LegacyMobileContentFormView {
            return formView
        }
        else if let paragraph = childView as? LegacyMobileContentParagraphView, let formView = paragraph.children.first as? LegacyMobileContentFormView {
            return formView
        }

        return nil
    }
    
    var isHiddenCard: Bool {
        return viewModel.isHiddenCard
    }
    
    func setDelegate(delegate: LegacyTractPageCardViewDelegate?) {
        self.delegate = delegate
    }
    
    func onCardVisible() {
        viewModel.cardDidAppear()
    }
    
    func onCardHidden() {
        viewModel.cardDidDisappear()
    }
    
    func containsDismissListener(eventId: EventId) -> Bool {
        return viewModel.containsDismissListener(eventId: eventId)
    }
    
    func containsListener(eventId: EventId) -> Bool {
        return viewModel.containsListener(eventId: eventId)
    }
    
    func setHeightConstraint(height: CGFloat) {
                
        if let heightConstraint = heightConstraint {
            heightConstraint.constant = height
        }
        else {
            heightConstraint = addHeightConstraint(constant: height)
        }
        
        layoutIfNeeded()
    }
    
    // MARK: - LegacyMobileContentView

    override func renderChild(childView: LegacyMobileContentView) {
                
        // NOTE: Currently the renderer will not return a view for Label xml nodes. If it did, we would see the card header label rendered twice.
        // We would have to ignore that here and not add it to the content stack. ~Levi
        
        contentStackView.renderChild(childView: childView)
        
        if let formView = searchChildForNestedForm(childView: childView) {
            self.formView = formView
            keyboardObserver.startObservingKeyboardChanges(delegate: self)
        }
    }
    
    override func viewDidAppear(navigationEvent: MobileContentPagesNavigationEvent?) {
        super.viewDidAppear(navigationEvent: navigationEvent)
        
        relayoutBottomGradient()
        
        if formView != nil {
            keyboardObserver.startObservingKeyboardChanges(delegate: self)
        }
    }
    
    override func viewDidDisappear() {
        keyboardObserver.stopObservingKeyboardChanges()
        formView?.resignCurrentEditedTextField()
    }
    
    // MARK: -
    
    static var minimumCardHeaderHeight: CGFloat {
        return 50
    }

    func getCardHeaderHeight() -> CGFloat {
        
        let minimumHeaderHeight: CGFloat = LegacyTractPageCardView.minimumCardHeaderHeight
        
        let headerHeight: CGFloat = titleSeparatorLine.frame.origin.y
        
        guard headerHeight > minimumHeaderHeight else {
            return minimumHeaderHeight
        }
        
        return headerHeight
    }
    
    @objc func headerTapped() {
        formView?.resignCurrentEditedTextField()
        delegate?.tractPageCardHeaderTapped(cardView: self)
    }
    
    @objc func previousTapped() {
        formView?.resignCurrentEditedTextField()
        delegate?.tractPageCardPreviousTapped(cardView: self)
    }
    
    @objc func nextTapped() {
        formView?.resignCurrentEditedTextField()
        delegate?.tractPageCardNextTapped(cardView: self)
    }
    
    @objc func handleSwipeGesture(swipeGesture: UISwipeGestureRecognizer) {
        
        guard let offset = contentStackView.getScrollViewContentOffset(), let inset = contentStackView.getScrollViewContentInset(), let scrollFrame = contentStackView.scrollViewFrame else {
            return
        }
        
        formView?.resignCurrentEditedTextField()
                
        if swipeGesture.direction == .up && offset.y + scrollFrame.size.height >= contentStackView.contentSize.height - inset.top - inset.bottom {
            delegate?.tractPageCardDidSwipeCardUp(cardView: self)
        } else if swipeGesture.direction == .down && offset.y <= 0 {
            delegate?.tractPageCardDidSwipeCardDown(cardView: self)
        }
    }
    
    private func setHeaderTrainingTipIconHidden(hidden: Bool) {
        
        headerTrainingTipImageView.isHidden = hidden
        
        if hidden {
            headerTrainingTipTrailing.constant = headerTrainingTipImageView.frame.size.width * -1
        }
        else {
            headerTrainingTipTrailing.constant = startingHeaderTrainingTipIconTrailing
        }
        
        layoutIfNeeded()
    }
}

// MARK: - KeyboardNotificationObserverDelegate

extension LegacyTractPageCardView: KeyboardNotificationObserverDelegate {
    
    func keyboardStateDidChange(keyboardObserver: KeyboardNotificationObserver, keyboardStateChange: KeyboardStateChange) {
        
        switch keyboardStateChange.keyboardState {
            
        case .willShow:
            keyboardHeightForAddedContentSize = keyboardStateChange.keyboardHeight
            
        case .willHide:
            break
            
        case .didShow:
            
            guard let keyboardHeight = keyboardHeightForAddedContentSize else {
                return
            }
            
            addKeyboardHeightToContentSize(keyboardHeight: CGFloat(keyboardHeight))
            
        case .didHide:
            
            removeKeyboardHeightFromContentSize()
        }
    }
    
    func keyboardHeightDidChange(keyboardObserver: KeyboardNotificationObserver, keyboardHeight: Double) {
        
    }
    
    private func addKeyboardHeightToContentSize(keyboardHeight: CGFloat) {
        
        guard !didAddKeyboardHeightToContentSize else {
            return
        }
        
        didAddKeyboardHeightToContentSize = true
        
        let scrollContentSize: CGSize = contentStackView.contentSize
        let contentHeight: CGFloat = scrollContentSize.height + keyboardHeight
        
        let contentSize: CGSize = CGSize(
            width: scrollContentSize.width,
            height: contentHeight
        )
        
        contentStackView.setScrollViewContentSize(size: contentSize)
    }
    
    private func removeKeyboardHeightFromContentSize() {
        
        guard let keyboardHeight = keyboardHeightForAddedContentSize else {
            return
        }
        
        guard didAddKeyboardHeightToContentSize else {
            return
        }
        
        didAddKeyboardHeightToContentSize = false
        
        let scrollContentSize: CGSize = contentStackView.contentSize
        let contentHeight: CGFloat = scrollContentSize.height - CGFloat(keyboardHeight)
        
        let contentSize: CGSize = CGSize(
            width: scrollContentSize.width,
            height: contentHeight
        )
        
        contentStackView.setScrollViewContentSize(size: contentSize)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension LegacyTractPageCardView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Card Swiping + ScrollViewDelegate

extension LegacyTractPageCardView: UIScrollViewDelegate {
    
    private func setCardSwipingEnabled(enabled: Bool) {
        
        if enabled && !cardSwipingIsEnabled {
            cardSwipingIsEnabled = true
            swipeUpGesture.isEnabled = true
            swipeDownGesture.isEnabled = true
        }
        else if !enabled && cardSwipingIsEnabled {
            cardSwipingIsEnabled = false
            swipeUpGesture.isEnabled = false
            swipeDownGesture.isEnabled = false
        }
    }
    
    private func getScrollViewContentOffset(scrollView: UIScrollView) -> CGFloat {
        return floor(scrollView.contentOffset.y)
    }
    
    private func getScrollViewContentTopOffset() -> CGFloat {
        return 0
    }
    
    private func getScrollViewContentBottomOffset(scrollView: UIScrollView) -> CGFloat {
        let scrollViewFrameHeight: CGFloat = getScrollViewFrameHeight(scrollView: scrollView)
        let contentBottomOffset: CGFloat = floor(scrollView.contentSize.height - scrollViewFrameHeight)
        return contentBottomOffset
    }
    
    private func didScrollToTopOfScrollView(scrollView: UIScrollView) -> Bool {
        getScrollViewContentOffset(scrollView: scrollView) <= getScrollViewContentTopOffset()
    }
    
    private func didScrollToBottomOfScrollView(scrollView: UIScrollView) -> Bool {
        getScrollViewContentOffset(scrollView: scrollView) >= getScrollViewContentBottomOffset(scrollView: scrollView)
    }
    
    private func handleScrollingEnded(scrollView: UIScrollView) {
        
        guard contentStackView.contentScrollViewIsEqualTo(otherScrollView: scrollView) else {
            return
        }
        
        guard cardSwipingIsEnabled else {
            return
        }
                
        let didScrollToTop: Bool = didScrollToTopOfScrollView(scrollView: scrollView)
        let didScrollToBottom: Bool = didScrollToBottomOfScrollView(scrollView: scrollView)
                
        if didScrollToTop {
            swipeUpGesture.isEnabled = false
            swipeDownGesture.isEnabled = true
        }
        else if didScrollToBottom {
            swipeUpGesture.isEnabled = true
            swipeDownGesture.isEnabled = false
        }
        else {
            swipeUpGesture.isEnabled = false
            swipeDownGesture.isEnabled = false
        }
    }
    
    private func getScrollViewFrameHeight(scrollView: UIScrollView) -> CGFloat {
        let scrollViewFrameHeight: CGFloat = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom
        return scrollViewFrameHeight
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        handleScrollingEnded(scrollView: scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        handleScrollingEnded(scrollView: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            handleScrollingEnded(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        handleScrollingEnded(scrollView: scrollView)
    }
}
