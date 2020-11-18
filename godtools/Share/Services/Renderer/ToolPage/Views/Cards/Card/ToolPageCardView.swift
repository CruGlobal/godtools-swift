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
    
    private var contentStackView: MobileContentStackView?
            
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var headerTrainingTipImageView: UIImageView!
    @IBOutlet weak private var titleSeparatorLine: UIView!
    @IBOutlet weak private var headerButton: UIButton!
    @IBOutlet weak private var contentStackContainer: UIView!
    @IBOutlet weak private var bottomGradientView: UIView!
    @IBOutlet weak private var cardPositionLabel: UILabel!
    @IBOutlet weak private var previousButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    
    required init(viewModel: ToolPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
        
        headerButton.addTarget(self, action: #selector(handleHeader(button:)), for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(handlePrevious(button:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(handleNext(button:)), for: .touchUpInside)
        
        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeUpGesture.delegate = self
        swipeUpGesture.direction = .up
        addGestureRecognizer(swipeUpGesture)
        
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeDownGesture.delegate = self
        swipeDownGesture.direction = .down
        addGestureRecognizer(swipeDownGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
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
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    private func setupBinding() {
                
        titleLabel.text = viewModel.title
        titleLabel.font = viewModel.titleFont
        titleLabel.textColor = viewModel.titleColor
        
        cardPositionLabel.text = viewModel.cardPositionLabel
        cardPositionLabel.textColor = viewModel.cardPositionLabelTextColor
        cardPositionLabel.font = viewModel.cardPositionLabelFont
        cardPositionLabel.isHidden = viewModel.hidesCardNavigation
        
        previousButton.setTitle(viewModel.previousButtonTitle, for: .normal)
        previousButton.setTitleColor(viewModel.previousButtonTitleColor, for: .normal)
        previousButton.isHidden = viewModel.hidesCardNavigation
        
        nextButton.setTitle(viewModel.nextButtonTitle, for: .normal)
        nextButton.setTitleColor(viewModel.nextButtonTitleColor, for: .normal)
        nextButton.isHidden = viewModel.hidesCardNavigation
        
        let contentStackViewModel: ToolPageContentStackViewModel = viewModel.contentStackViewModel
        let contentStackView: MobileContentStackView = MobileContentStackView(viewModel: contentStackViewModel, itemSpacing: 20, scrollIsEnabled: true)
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
        contentStackView.setScollBarsHidden(hidden: true)
        
        contentStackViewModel.containsTips.addObserver(self) { [weak self] (containsTips: Bool) in
            self?.headerTrainingTipImageView.isHidden = !containsTips
        }
    }
    
    var cardHeaderHeight: CGFloat {
        return 50
    }
    
    @objc func handleHeader(button: UIButton) {
        viewModel.headerTapped()
    }
    
    @objc func handlePrevious(button: UIButton) {
        viewModel.previousTapped()
    }
    
    @objc func handleNext(button: UIButton) {
        viewModel.nextTapped()
    }
    
    @objc func handleSwipeGesture(swipeGesture: UISwipeGestureRecognizer) {
        
        guard let contentStackView = self.contentStackView else {
            return
        }
        
        guard let offset = contentStackView.getContentOffset(), let inset = contentStackView.getContentInset(), let scrollFrame = contentStackView.scrollViewFrame else {
            return
        }
                
        if swipeGesture.direction == .up && offset.y + scrollFrame.size.height >= contentStackView.contentSize.height - inset.top - inset.bottom {
            viewModel.didSwipeCardUp()
        } else if swipeGesture.direction == .down && offset.y <= 0 {
            viewModel.didSwipeCardDown()
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
            
            let scrollViewFrameHeight: CGFloat = otherScrollView.frame.size.height - otherScrollView.contentInset.top - otherScrollView.contentInset.bottom
                                    
            if otherScrollView.contentOffset.y <= 0 {
                return true
            }
            else if otherScrollView.contentOffset.y + scrollViewFrameHeight >= otherScrollView.contentSize.height {
                return true
            }
            
            return false
        }
        
        return false
    }
}
