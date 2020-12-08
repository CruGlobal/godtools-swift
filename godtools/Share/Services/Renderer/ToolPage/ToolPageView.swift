//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageView: UIView, ReusableView {
    
    private let panGestureToControlPageCollectionViewPanningSensitivity: UIPanGestureRecognizer = UIPanGestureRecognizer()
    private let backgroundImageView: MobileContentBackgroundImageView = MobileContentBackgroundImageView()
    
    private var viewModel: ToolPageViewModelType?
    private var safeArea: UIEdgeInsets = .zero
    private var cardsView: ToolPageCardsView = ToolPageCardsView()
    private var toolModal: ToolPageModalView?
    
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
        setupLayout()
        
        callToActionNextButton.addTarget(self, action: #selector(handleCallToActionNext(button:)), for: .touchUpInside)
        
        addGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
        panGestureToControlPageCollectionViewPanningSensitivity.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
        
        headerTrainingTipView.backgroundColor = .clear
    }
    
    func resetView() {
        
        contentStackContainerView.removeAllSubviews()
        headerTrainingTipView.removeAllSubviews()
        heroContainerView.removeAllSubviews()
        dismissModalIfNeeded(animated: false, completion: nil)
        cardsView.resetView()
        viewModel?.hidesHeaderTrainingTip.removeObserver(self)
        viewModel?.modal.removeObserver(self)
        viewModel = nil
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
        callToActionNextButton.semanticContentAttribute = callToActionViewModel.semanticContentAttribute
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
        
        //
        let hidesHeader: Bool = viewModel.headerViewModel.hidesHeader
        let hidesCallToAction: Bool = viewModel.callToActionViewModel.hidesCallToAction
        
        // contentStack
        if let contentStackViewModel = viewModel.contentStackViewModel {
            let contentStackView: MobileContentStackView = MobileContentStackView(viewRenderer: contentStackViewModel.contentStackRenderer, itemSpacing: 20, scrollIsEnabled: true)
            contentStackContainerView.addSubview(contentStackView)
            contentStackView.constrainEdgesToSuperview()
            contentStackContainerView.isHidden = false
            contentStackContainerView.layoutIfNeeded()
        }
        else {
            contentStackContainerView.isHidden = true
        }
        
        setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: hidesHeader, animated: false)
        setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: hidesCallToAction, animated: false)
                
        //cards
        cardsView.configure(
            parentView: self,
            viewModel: viewModel,
            safeArea: safeArea,
            callToActionView: callToActionView,
            delegate: self
        )
        
        // hero top and height
        if let heroViewModel = viewModel.heroViewModel {
            
            let hidesCards: Bool = viewModel.numberOfVisibleCards == 0
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
                
                guard let cardView = cardsView.getFirstCard() else {
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
        
        // TODO: Is this method needed? ~Levi
        
        let heroTopContentInset: CGFloat
        
        if !hidesHeader {
            heroTopContentInset = headerView.frame.size.height + 20
        }
        else {
            heroTopContentInset = 30
        }
        
        //heroView?.setContentInset(contentInset: UIEdgeInsets(top: heroTopContentInset, left: 0, bottom: 0, right: 0))
        //heroView?.setContentOffset(contentOffset: CGPoint(x: 0, y: heroTopContentInset * -1))
    }
    
    private func setHeaderHidden(headerViewModel: ToolPageHeaderViewModel, hidden: Bool, animated: Bool) {
             
        let attemptingToShowHeader: Bool = !hidden
        if attemptingToShowHeader && headerViewModel.hidesHeader {
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
        
        let attemptingToShowCallToAction: Bool = !hidden
        if attemptingToShowCallToAction && callToActionViewModel.hidesCallToAction {
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

// MARK: - ToolPageCardsViewDelegate

extension ToolPageView: ToolPageCardsViewDelegate {
    
    func toolPageCardsStateDidChange(toolPageCards: ToolPageCardsView, viewModel: ToolPageViewModelType, cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
            
        case .starting:
            
            setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: false, animated: animated)
            setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: true, animated: animated)
            
        case .showingCard(let showingCardAtPosition):
            
            guard let showCardAtPosition = showingCardAtPosition else {
                return
            }
            
            setHeaderHidden(headerViewModel: viewModel.headerViewModel, hidden: true, animated: animated)
            let isShowingLastVisibleCard: Bool = showCardAtPosition >= viewModel.numberOfVisibleCards - 1
            setCallToActionHidden(callToActionViewModel: viewModel.callToActionViewModel, hidden: !isShowingLastVisibleCard, animated: animated)
            
        case .showingKeyboard(let showingCardAtPosition):
            break
            
        case .collapseAllCards:
            break
            
        case .initialized:
            break
        }
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
