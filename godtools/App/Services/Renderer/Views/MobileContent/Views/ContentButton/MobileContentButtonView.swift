//
//  MobileContentButtonView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation
import UIKit

class MobileContentButtonView: MobileContentView {
        
    private let viewModel: MobileContentButtonViewModel
    private let buttonView: UIView = UIView()
    private let buttonTitle: UILabel = UILabel()
    private let buttonImagePaddingToButtonTitle: CGFloat = 12
    private let minimumButtonHeight: CGFloat = 21
    private let buttonTopAndBottomPaddingToTitle: CGFloat = 8
    
    private var buttonTitleSizeToFitSize: CGSize?
    private var buttonImageView: UIImageView?
    private var buttonViewWidthConstraint: NSLayoutConstraint?
    private var buttonTitleWidthForIconConstraint: NSLayoutConstraint?
    
    init(viewModel: MobileContentButtonViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        addSubviewsAndConstraints(buttonView: buttonView, buttonTitle: buttonTitle, buttonImageView: buttonImageView)
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutButtonViewWidthIfNeeded()
    }
    
    private func setupLayout() {
                
        backgroundColor = .clear
                
        // buttonView
        buttonView.backgroundColor = viewModel.backgroundColor
        buttonView.layer.cornerRadius = 5
        
        if let borderColor = viewModel.borderColor, let borderWidth = viewModel.borderWidth {
            buttonView.layer.borderColor = borderColor.cgColor
            buttonView.layer.borderWidth = borderWidth
        }
        
        // buttonTitle
        buttonTitle.isUserInteractionEnabled = false
        buttonTitle.backgroundColor = .clear
        buttonTitle.numberOfLines = 0
        buttonTitle.lineBreakMode = .byWordWrapping
        buttonTitle.textAlignment = .center
        buttonTitle.font = viewModel.font
        buttonTitle.text = viewModel.title
        buttonTitle.textColor = viewModel.titleColor
              
        buttonTitle.sizeToFit()
        buttonTitleSizeToFitSize = buttonTitle.frame.size
        
        // buttonImageView
        if let buttonIcon = viewModel.icon {
            
            let buttonImageView: UIImageView = UIImageView(image: buttonIcon.image)
            buttonImageView.isUserInteractionEnabled = false
            buttonImageView.backgroundColor = .clear
            
            self.buttonImageView = buttonImageView
        }
    }
    
    private func addSubviewsAndConstraints(buttonView: UIView, buttonTitle: UILabel, buttonImageView: UIImageView?) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // buttonView
        addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        _ = buttonView.constrainTopToView(view: self)
        _ = buttonView.constrainBottomToView(view: self)
        
        _ = buttonView.addHeightConstraint(
            constant: minimumButtonHeight,
            relatedBy: .greaterThanOrEqual,
            priority: 1000
        )
        
        buttonView.constrainCenterHorizontallyInView(view: self)
        
        let buttonViewWidth: CGFloat = getButtonViewWidth()
        
        buttonViewWidthConstraint = buttonView.addWidthConstraint(constant: buttonViewWidth)
        
        // buttonTitle
        buttonView.addSubview(buttonTitle)
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        _ = buttonTitle.constrainTopToView(view: buttonView, constant: buttonTopAndBottomPaddingToTitle)
        _ = buttonTitle.constrainBottomToView(view: buttonView, constant: buttonTopAndBottomPaddingToTitle)
                
        if let buttonImageView = buttonImageView, let buttonIcon = viewModel.icon, let buttonIconSize = getButtonIconSize(), let buttonTitleWidth = getButtonTitleWidth() {
            
            buttonTitle.constrainCenterHorizontallyInView(view: buttonView)
            buttonTitleWidthForIconConstraint = buttonTitle.addWidthConstraint(constant: buttonTitleWidth)
                        
            buttonView.addSubview(buttonImageView)
            buttonImageView.translatesAutoresizingMaskIntoConstraints = false
            buttonImageView.constrainCenterVerticallyInView(view: self)
            _ = buttonImageView.addWidthConstraint(constant: buttonIconSize.width)
            _ = buttonImageView.addHeightConstraint(constant: buttonIconSize.height)
            
            switch buttonIcon.gravity {
            
            case .start:
                
                let trailing: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0
                )
                
                buttonView.addConstraint(trailing)
                
            case .end:
                
                let leading: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: 0
                )
                
                buttonView.addConstraint(leading)
            
            default:
                
                let trailing: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .leading,
                    multiplier: 1,
                    constant: 0
                )
                
                buttonView.addConstraint(trailing)
            }
        }
        else {
            
            _ = buttonTitle.constrainLeadingToView(view: buttonView)
            _ = buttonTitle.constrainTrailingToView(view: buttonView)
        }
    }
    
    private func getButtonViewWidth() -> CGFloat {
        
        let buttonViewWidth: CGFloat
        
        switch viewModel.buttonWidth {
        
        case .percentageOfContainer(let widthPercentageOfContainer):
            buttonViewWidth = containerWidth * widthPercentageOfContainer
        
        case .points(let widthPoints):
            buttonViewWidth = widthPoints
        }
        
        return buttonViewWidth
    }
    
    private func getButtonTitleWidth() -> CGFloat? {
        
        guard let buttonTitleSizeToFitSize = self.buttonTitleSizeToFitSize, let buttonIconSize = getButtonIconSize() else {
            return nil
        }
        
        let buttonViewWidth: CGFloat = getButtonViewWidth()
        
        let minSuggestedButtonTitleWidth: CGFloat = buttonViewWidth / 4
        var suggestedButtonTitleWidth: CGFloat = buttonViewWidth - (buttonIconSize.width * 2) - (buttonImagePaddingToButtonTitle * 4)
        
        if suggestedButtonTitleWidth < minSuggestedButtonTitleWidth {
            suggestedButtonTitleWidth = minSuggestedButtonTitleWidth
        }
        
        if buttonTitleSizeToFitSize.width > suggestedButtonTitleWidth {
            return suggestedButtonTitleWidth
        }
        
        return buttonTitleSizeToFitSize.width + (buttonImagePaddingToButtonTitle * 2)
    }
    
    private func getButtonIconSize() -> CGSize? {
        
        guard let buttonIcon = viewModel.icon else {
            return nil
        }
        
        let buttonIconWidth: CGFloat = CGFloat(buttonIcon.size)
        let buttonIconHeight: CGFloat = CGFloat(buttonIcon.size)
        
        return CGSize(width: buttonIconWidth, height: buttonIconHeight)
    }
    
    private func setupBinding() {
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
    
    private var containerWidth: CGFloat {
        return frame.size.width
    }
    
    private func layoutButtonViewWidthIfNeeded() {
                
        buttonViewWidthConstraint?.constant = getButtonViewWidth()
            
        if let buttonTitleWidth = getButtonTitleWidth() {
            
            buttonTitleWidthForIconConstraint?.constant = buttonTitleWidth
        }

        layoutIfNeeded()
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
