//
//  ToolPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/27/20.
//  Copyright © 2020 Cru. All rights reserved.
//
import UIKit

protocol ToolPageViewDelegate: AnyObject {
    
    func toolPageCardPositionChanged(pageView: ToolPageView, page: Int, cardPosition: Int?, animated: Bool)
    func toolPageCallToActionNextButtonTapped(pageView: ToolPageView, page: Int)
}

class ToolPageView: MobileContentPageView {
    
    private let viewModel: ToolPageViewModel
    private let safeArea: UIEdgeInsets
    private let panGestureToControlPageCollectionViewPanningSensitivity: UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    private var headerView: ToolPageHeaderView?
    private var heroView: ToolPageHeroView?
    private var callToActionView: ToolPageCallToActionView?
    private var cardsView: ToolPageCardsView?
    private var bottomView: UIView?
    
    private weak var delegate: ToolPageViewDelegate?
        
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var headerContainerView: UIView!
    @IBOutlet weak private var heroContainerView: UIView!
    @IBOutlet weak private var callToActionContainerView: UIView!
    
    @IBOutlet weak private var topInsetTopConstraint: NSLayoutConstraint!
    @IBOutlet weak private var headerTop: NSLayoutConstraint!
    @IBOutlet weak private var heroTop: NSLayoutConstraint!
    @IBOutlet weak private var heroHeight: NSLayoutConstraint!
    @IBOutlet weak private var callToActionBottom: NSLayoutConstraint!
    @IBOutlet weak private var bottomInsetBottomConstraint: NSLayoutConstraint!
    
    init(viewModel: ToolPageViewModel, safeArea: UIEdgeInsets) {
        
        self.viewModel = viewModel
        self.safeArea = safeArea
        
        super.init(viewModel: viewModel, nibName: String(describing: ToolPageView.self))
                
        addGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
        panGestureToControlPageCollectionViewPanningSensitivity.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
        
        removeGestureRecognizer(panGestureToControlPageCollectionViewPanningSensitivity)
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        topInsetTopConstraint.constant = safeArea.top
        bottomInsetBottomConstraint.constant = safeArea.bottom
        
        // headerContainerView
        headerContainerView.isHidden = true
        headerContainerView.backgroundColor = .clear
        setHeaderHidden(hidden: true, animated: false)
        
        // heroContainerView
        heroContainerView.isHidden = true
        heroContainerView.backgroundColor = .clear
        
        // callToActionContainerView
        callToActionContainerView.isHidden = true
        callToActionContainerView.backgroundColor = .clear
        setCallToActionHidden(hidden: true, animated: false)
    }
    
    override func setupBinding() {
        super.setupBinding()
    }
    
    override func getPositionState() -> MobileContentViewPositionState {
        
        let cardPosition: Int? = cardsView?.getCurrentCardPosition()
        
        return ToolPagePositions(cardPosition: cardPosition)
    }
    
    override func setPositionState(positionState: MobileContentViewPositionState, animated: Bool) {
        
        guard let toolPagePositions = positionState as? ToolPagePositions else {
            return
        }
        
        cardsView?.setRenderedCardsState(cardsState: .showingCard(showingCardAtPosition: toolPagePositions.cardPosition), animated: animated)
    }
    
    // MARK: - MobileContentView

    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let headerView = childView as? ToolPageHeaderView {
            addHeaderView(headerView: headerView)
        }
        else if let callToActionView = childView as? ToolPageCallToActionView {
            addCallToActionView(callToActionView: callToActionView)
        }
        else if let heroView = childView as? ToolPageHeroView {
            addHeroView(heroView: heroView)
        }
        else if let cardsView = childView as? ToolPageCardsView {
            self.cardsView = cardsView
            cardsView.setCardsViewDelegate(delegate: self)
        }
    }

    override func finishedRenderingChildren() {
        
        if callToActionView == nil && !viewModel.hidesCallToAction, let callToActionView = viewModel.callToActionWillAppear() {
            addCallToActionView(callToActionView: callToActionView)
        }
        
        cardsView?.renderCardsInParentView(renderedCardsParentView: self, cardInsets: getCardContentInsets())
        
        addBottomView()
                
        updateHeroPosition(numberOfVisibleCards: viewModel.numberOfVisibleCards)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        viewModel.pageDidAppear()
    }
    
    // MARK: -
    
    private func getCardContentInsets() -> UIEdgeInsets {
        
        let callToActionHeight: CGFloat = callToActionView?.frame.size.height ?? 0
                
        return UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: callToActionHeight,
            right: 0
        )
    }
    
    func setToolPageDelegate(delegate: ToolPageViewDelegate?) {
        self.delegate = delegate
    }
}

// MARK: - Header

extension ToolPageView {
    
    private func addHeaderView(headerView: ToolPageHeaderView) {
        
        guard self.headerView == nil else {
            return
        }
        
        headerContainerView.isHidden = false
        headerContainerView.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.constrainEdgesToView(view: headerContainerView)
        self.headerView = headerView
        
        setHeaderHidden(hidden: false, animated: false)
    }
    
    private func setHeaderHidden(hidden: Bool, animated: Bool) {
                 
        let headerShouldBeHidden: Bool = headerView == nil
                
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
            }, completion: nil)
        }
        else {
            layoutIfNeeded()
            headerContainerView.alpha = headerAlpha
        }
    }
}

// MARK: - Hero

extension ToolPageView {
    
    private func addHeroView(heroView: ToolPageHeroView) {
        
        guard self.heroView == nil else {
            return
        }
        
        heroContainerView.isHidden = false
        heroContainerView.addSubview(heroView)
        heroView.translatesAutoresizingMaskIntoConstraints = false
        heroView.constrainEdgesToView(view: heroContainerView)
        self.heroView = heroView
    }
    
    private func updateHeroPosition(numberOfVisibleCards: Int) {
        
        if self.heroView == nil {
            return
        }
        
        let hidesCards: Bool = numberOfVisibleCards == 0
        let hidesCallToAction: Bool = viewModel.hidesCallToAction
        
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
            
            let combineCardHeaderHeight: CGFloat = cardsView?.getCombinedCardHeaderHeightForRenderedCards() ?? 0
            heroHeight.constant = maximumHeight - combineCardHeaderHeight
        }
                     
        heroTop.constant = headerHeight + topInset
        layoutIfNeeded()
    }
}

// MARK: - Call To Action, ToolPageCallToActionViewDelegate

extension ToolPageView: ToolPageCallToActionViewDelegate {
    
    private func addCallToActionView(callToActionView: ToolPageCallToActionView) {
        
        guard self.callToActionView == nil else {
            return
        }
                
        callToActionContainerView.isHidden = false
        callToActionContainerView.addSubview(callToActionView)
        callToActionView.translatesAutoresizingMaskIntoConstraints = false
        callToActionView.constrainEdgesToView(view: callToActionContainerView)
        self.callToActionView = callToActionView
        
        callToActionContainerView.layoutIfNeeded()
        
        setCallToActionHidden(hidden: false, animated: false)
        
        callToActionView.setDelegate(delegate: self)
    }
    
    private func setCallToActionHidden(hidden: Bool, animated: Bool) {
        
        let callToActionShouldBeHidden: Bool = viewModel.hidesCallToAction || callToActionView == nil
        
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
    
    func toolPageCallToActionNextButtonTapped(callToActionView: ToolPageCallToActionView) {
        
        delegate?.toolPageCallToActionNextButtonTapped(pageView: self, page: viewModel.page)
    }
}

// MARK: - ToolPageCardsViewDelegate

extension ToolPageView: ToolPageCardsViewDelegate {
    
    func toolPageCardsDidChangeCardPosition(cardsView: ToolPageCardsView, cardPosition: Int?, animated: Bool) {
        
        delegate?.toolPageCardPositionChanged(pageView: self, page: viewModel.page, cardPosition: cardPosition, animated: animated)
        
        viewModel.didChangeCardPosition(cardPosition: cardPosition)
    }
    
    func toolPageCardsDidChangeCardState(cardsView: ToolPageCardsView, cardsState: ToolPageCardsState, animated: Bool) {
        
        switch cardsState {
        
        case .starting:
            setHeaderHidden(hidden: false, animated: animated)
            setCallToActionHidden(hidden: true, animated: animated)
            
        case .showingCard(let showingCardAtPosition):
            
            guard let cardPosition = showingCardAtPosition else {
                return
            }
            
            let isShowingLastVisibleCard: Bool = cardPosition >= cardsView.getNumberOfRenderedCards() - 1
            
            setHeaderHidden(hidden: true, animated: animated)
            setCallToActionHidden(hidden: !isShowingLastVisibleCard, animated: animated)
            
        case .showingKeyboard( _):
            break
            
        case .collapseAllCards:
            break
            
        case .initialized:
            break
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
