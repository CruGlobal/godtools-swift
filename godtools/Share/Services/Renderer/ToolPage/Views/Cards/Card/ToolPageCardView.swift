//
//  ToolPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 11/3/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageCardView: UIView {
        
    private let viewModel: ToolPageCardViewModelType
    private let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
    private let swipeUpGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    private let swipeDownGesture: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
    
    private lazy var keyboardObserver: KeyboardObserverType = KeyboardNotificationObserver(loggingEnabled: false)
    
    private var contentStackView: MobileContentStackView?
    private var contentFormView: ToolPageContentFormView?
    private var startingHeaderTrainingTipIconTrailing: CGFloat = 20
    private var keyboardHeightForAddedContentSize: Double?
    private var didAddKeyboardHeightToContentSize: Bool = false
    private var cardSwipingIsEnabled: Bool = false
            
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
    
    required init(viewModel: ToolPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        headerButton.addTarget(self, action: #selector(handleHeader(button:)), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(handlePrevious(button:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext(button:)), for: .touchUpInside)
        
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
        keyboardObserver.stopObservingKeyboardChanges()
        keyboardObserver.keyboardStateDidChangeSignal.removeObserver(self)
        keyboardObserver.keyboardHeightDidChangeSignal.removeObserver(self)
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageCardView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
        let cardCornerRadius: CGFloat = 8
        
        startingHeaderTrainingTipIconTrailing = headerTrainingTipTrailing.constant
        
        // shadow
        layer.cornerRadius = cardCornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 6.0
        layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        layer.shadowOpacity = 0.3
        clipsToBounds = false
        
        // background corner radius
        let rootView: UIView? = subviews.first
        rootView?.layer.cornerRadius = cardCornerRadius
        rootView?.clipsToBounds = true
        
        // bottom gradient
        bottomGradientView.isUserInteractionEnabled = false
        bottomGradientView.backgroundColor = .clear
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    private func setupBinding() {
              
        backgroundImageView.configure(viewModel: viewModel.backgroundImageWillAppear(), parentView: cardBackgroundImageContainer)
        
        titleLabel.text = viewModel.title
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleColor
        titleLabel.textAlignment = viewModel.titleAlignment
        
        viewModel.hidesHeaderTrainingTip.addObserver(self) { [weak self] (hidesHeaderTrainingTip: Bool) in
            self?.setHeaderTrainingTipIconHidden(hidden: hidesHeaderTrainingTip)
        }
        
        cardPositionLabel.text = viewModel.cardPositionLabel
        cardPositionLabel.textColor = viewModel.cardPositionLabelTextColor
        cardPositionLabel.font = viewModel.cardPositionLabelFont
        cardPositionLabel.isHidden = viewModel.hidesCardPositionLabel
        
        previousButton.setTitle(viewModel.previousButtonTitle, for: .normal)
        previousButton.setTitleColor(viewModel.previousButtonTitleColor, for: .normal)
        previousButton.isHidden = viewModel.hidesPreviousButton
        
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
        nextButton.setTitleColor(viewModel.nextButtonTitleColor, for: .normal)
        nextButton.isHidden = viewModel.hidesNextButton
        
        let contentStackViewModel: ToolPageContentStackContainerViewModel = viewModel.contentStackViewModel
        
        contentStackViewModel.contentStackRenderer.didRenderContentFormSignal.addObserver(self) { [weak self] (contentForm: ToolPageContentFormView) in
            self?.handleDidRenderContentForm(form: contentForm)
        }
        
        let contentStackView: MobileContentStackView = MobileContentStackView(viewRenderer: contentStackViewModel.contentStackRenderer, itemSpacing: 20, scrollIsEnabled: true)
        contentStackContainer.addSubview(contentStackView)
        contentStackView.constrainEdgesToSuperview()
        layoutIfNeeded()
        self.contentStackView = contentStackView
        contentStackView.setContentInset(contentInset: UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: bottomGradientView.frame.size.height,
            right: 0
        ))
        contentStackView.setScrollViewDelegate(delegate: self)
    }
    
    var cardHeaderHeight: CGFloat {
        return 50
    }
    
    @objc func handleHeader(button: UIButton) {
        contentFormView?.resignCurrentEditedTextField()
        viewModel.headerTapped()
    }
    
    @objc func handlePrevious(button: UIButton) {
        contentFormView?.resignCurrentEditedTextField()
        viewModel.previousTapped()
    }
    
    @objc func handleNext(button: UIButton) {
        contentFormView?.resignCurrentEditedTextField()
        viewModel.nextTapped()
    }
    
    @objc func handleSwipeGesture(swipeGesture: UISwipeGestureRecognizer) {
        
        guard let contentStackView = self.contentStackView else {
            return
        }
        
        guard let offset = contentStackView.getContentOffset(), let inset = contentStackView.getContentInset(), let scrollFrame = contentStackView.scrollViewFrame else {
            return
        }
        
        contentFormView?.resignCurrentEditedTextField()
                
        if swipeGesture.direction == .up && offset.y + scrollFrame.size.height >= contentStackView.contentSize.height - inset.top - inset.bottom {
            viewModel.didSwipeCardUp()
        } else if swipeGesture.direction == .down && offset.y <= 0 {
            viewModel.didSwipeCardDown()
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
    
    private func handleDidRenderContentForm(form: ToolPageContentFormView) {
        
        guard self.contentFormView == nil else {
            return
        }
        
        self.contentFormView = form
        
        keyboardObserver.startObservingKeyboardChanges()
        keyboardObserver.keyboardStateDidChangeSignal.addObserver(self) { [weak self] (keyboardStateChange: KeyboardStateChange) in
            self?.handleKeyboardStateChange(keyboardStateChange: keyboardStateChange)
        }
        
        keyboardObserver.keyboardHeightDidChangeSignal.addObserver(self) { [weak self] (height: Double) in
            self?.handleKeyboardHeightChange(height: height)
        }
    }
    
    private func handleKeyboardStateChange(keyboardStateChange: KeyboardStateChange) {
        
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
    
    private func handleKeyboardHeightChange(height: Double) {

    }
    
    private func addKeyboardHeightToContentSize(keyboardHeight: CGFloat) {
        
        guard let scrollContentSize = contentStackView?.contentSize else {
            return
        }
        
        guard !didAddKeyboardHeightToContentSize else {
            return
        }
        
        didAddKeyboardHeightToContentSize = true
        
        let contentHeight: CGFloat = scrollContentSize.height + keyboardHeight
        
        let contentSize: CGSize = CGSize(
            width: scrollContentSize.width,
            height: contentHeight
        )
        
        contentStackView?.setContentSize(size: contentSize)
    }
    
    private func removeKeyboardHeightFromContentSize() {
        
        guard let scrollContentSize = contentStackView?.contentSize else {
            return
        }
        
        guard let keyboardHeight = keyboardHeightForAddedContentSize else {
            return
        }
        
        guard didAddKeyboardHeightToContentSize else {
            return
        }
        
        didAddKeyboardHeightToContentSize = false
        
        let contentHeight: CGFloat = scrollContentSize.height - CGFloat(keyboardHeight)
        
        let contentSize: CGSize = CGSize(
            width: scrollContentSize.width,
            height: contentHeight
        )
        
        contentStackView?.setContentSize(size: contentSize)
    }
    
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
    
    private func handleScroll(scrollView: UIScrollView) {
        
        guard let contentStackView = self.contentStackView, contentStackView.contentScrollViewIsEqualTo(otherScrollView: scrollView) else {
            return
        }
        
        guard cardSwipingIsEnabled else {
            return
        }
        
        let scrollViewFrameHeight: CGFloat = getScrollViewFrameHeight(scrollView: scrollView)
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < scrollView.contentSize.height - scrollViewFrameHeight {
            swipeUpGesture.isEnabled = false
            swipeDownGesture.isEnabled = false
        }
    }
    
    private func handleScrollingEnded(scrollView: UIScrollView) {
        
        guard let contentStackView = self.contentStackView, contentStackView.contentScrollViewIsEqualTo(otherScrollView: scrollView) else {
            return
        }
        
        guard cardSwipingIsEnabled else {
            return
        }
                
        let scrollViewFrameHeight: CGFloat = getScrollViewFrameHeight(scrollView: scrollView)
        let didScrollToTop: Bool = scrollView.contentOffset.y <= 0
        let didScrollToBottom: Bool = scrollView.contentOffset.y >= scrollView.contentSize.height - scrollViewFrameHeight
        
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
}

// MARK: - UIGestureRecognizerDelegate

extension ToolPageCardView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                
        guard let contentStackView = self.contentStackView else {
            return false
        }
        
        if let otherScrollView = otherGestureRecognizer.view as? UIScrollView, contentStackView.contentScrollViewIsEqualTo(otherScrollView: otherScrollView) {
            
            let scrollViewFrameHeight: CGFloat = getScrollViewFrameHeight(scrollView: otherScrollView)
            let didScrollToTop: Bool = otherScrollView.contentOffset.y <= 0
            let didScrollToBottom: Bool = otherScrollView.contentOffset.y >= otherScrollView.contentSize.height - scrollViewFrameHeight
            
            if didScrollToTop {
                return true
            }
            else if didScrollToBottom {
                return true
            }
            
            return false
        }
        
        return false
    }
}

// MARK: - ScrollViewDelegate

extension ToolPageCardView: UIScrollViewDelegate {
    
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
