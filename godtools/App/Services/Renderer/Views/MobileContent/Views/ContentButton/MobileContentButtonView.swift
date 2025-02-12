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
        
    private static let topPadding: CGFloat = 4
    private static let bottomPadding: CGFloat = 4
    
    private let viewModel: MobileContentButtonViewModel
    private let buttonView: UIView = UIView()
    private let buttonTitle: UILabel = UILabel()
    private let buttonImagePaddingToButtonTitle: CGFloat = 12
    private let buttonTitleImagePaddingToEdge: CGFloat = 10
    private let minimumButtonHeight: CGFloat = 21
    private let buttonTopAndBottomPaddingToTitle: CGFloat = 8
    private let contentInsets: UIEdgeInsets
    
    private var buttonImageView: UIImageView?
    private var buttonViewWidthConstraint: NSLayoutConstraint?
    private var buttonTitleWidthForIconConstraint: NSLayoutConstraint?
    
    init(viewModel: MobileContentButtonViewModel) {
        
        self.viewModel = viewModel
        self.contentInsets = UIEdgeInsets(top: Self.topPadding, left: 0, bottom: Self.bottomPadding, right: 0)
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        addSubviewsAndConstraints(buttonView: buttonView, buttonTitle: buttonTitle, buttonImageView: buttonImageView)
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        buttonTitle.font = viewModel.font
        setTitle(title: viewModel.title)
        buttonTitle.textColor = viewModel.titleColor
        
        // buttonImageView
        if let buttonIcon = viewModel.icon {
            
            let buttonImageView: UIImageView = UIImageView(image: buttonIcon.image)
            buttonImageView.isUserInteractionEnabled = false
            buttonImageView.backgroundColor = .clear
            
            self.buttonImageView = buttonImageView
        }
    }
    
    private func setupBinding() {
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
    
    private func addSubviewsAndConstraints(buttonView: UIView, buttonTitle: UILabel, buttonImageView: UIImageView?) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // buttonView
        addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        _ = buttonView.constrainTopToView(view: self, constant: contentInsets.top)
        _ = buttonView.constrainBottomToView(view: self, constant: contentInsets.bottom)
        
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
                
        let buttonHorizontalPadding: CGFloat = viewModel.titleAlignment == .center ? 0 : buttonTitleImagePaddingToEdge
        let buttonTitleTextAlignment: NSTextAlignment
        
        if let buttonImageView = buttonImageView, let buttonIcon = viewModel.icon, let buttonIconSize = getButtonIconSize() {
            
            buttonTitleTextAlignment = .center
            
            buttonTitleWidthForIconConstraint = buttonTitle.addWidthConstraint(constant: titleWidth)
            
            buttonView.addSubview(buttonImageView)
            buttonImageView.translatesAutoresizingMaskIntoConstraints = false
            buttonImageView.constrainCenterVerticallyInView(view: self)
            _ = buttonImageView.addWidthConstraint(constant: buttonIconSize.width)
            _ = buttonImageView.addHeightConstraint(constant: buttonIconSize.height)
            
            let renderButtonIconLeftOfTitle: Bool
            
            switch buttonIcon.gravity {
            
            case .start:
                renderButtonIconLeftOfTitle = true

            case .end:
                renderButtonIconLeftOfTitle = false
            
            default:
                renderButtonIconLeftOfTitle = true
            }
            
            if renderButtonIconLeftOfTitle {
                
                let trailing: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .leading,
                    multiplier: 1,
                    constant: buttonImagePaddingToButtonTitle * -1
                )
                
                buttonView.addConstraint(trailing)
            }
            else {
                
                let leading: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: buttonImagePaddingToButtonTitle
                )
                
                buttonView.addConstraint(leading)
            }
            
            if viewModel.titleAlignment == .center {
                
                let offsetWidth: CGFloat = (buttonIconSize.width + buttonImagePaddingToButtonTitle) / 2
                let offsetMultiplier: CGFloat = renderButtonIconLeftOfTitle ? 1 : -1
                let offset: CGFloat = offsetWidth * offsetMultiplier
                
                buttonTitle.constrainCenterHorizontallyInView(view: buttonView, constant: offset)
            }
            else if viewModel.titleAlignment == .left {
                
                let leadingView: UIView = renderButtonIconLeftOfTitle ? buttonImageView : buttonTitle
                _ = leadingView.constrainLeadingToView(view: buttonView, constant: buttonHorizontalPadding)
            }
            else if viewModel.titleAlignment == .right {
                
                let trailingView: UIView = renderButtonIconLeftOfTitle ? buttonTitle : buttonImageView
                _ = trailingView.constrainTrailingToView(view: buttonView, constant: buttonHorizontalPadding)
            }
            else {
                
                buttonTitle.constrainCenterHorizontallyInView(view: buttonView)
            }
        }
        else {
            
            buttonTitleTextAlignment = viewModel.titleAlignment
            
            _ = buttonTitle.constrainLeadingToView(view: buttonView, constant: buttonHorizontalPadding)
            _ = buttonTitle.constrainTrailingToView(view: buttonView, constant: buttonHorizontalPadding)
        }
        
        buttonTitle.textAlignment = buttonTitleTextAlignment
    }
    
    private var titleWidth: CGFloat {
        return buttonTitle.frame.size.width
    }
    
    private func setTitle(title: String?) {
        
        buttonTitle.text = viewModel.title
        buttonTitle.sizeToFit()
        
        if buttonTitleWidthForIconConstraint != nil {
            
            buttonTitleWidthForIconConstraint?.constant = titleWidth
            layoutIfNeeded()
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
    
    private func getButtonIconSize() -> CGSize? {
        
        guard let buttonIcon = viewModel.icon else {
            return nil
        }
        
        let buttonIconWidth: CGFloat = CGFloat(buttonIcon.size)
        let buttonIconHeight: CGFloat = CGFloat(buttonIcon.size)
        
        return CGSize(width: buttonIconWidth, height: buttonIconHeight)
    }
    
    private var containerWidth: CGFloat {
        return frame.size.width
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
