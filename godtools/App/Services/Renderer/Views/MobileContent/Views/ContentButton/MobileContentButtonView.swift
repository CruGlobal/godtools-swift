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
    
    private static let buttonHeight: CGFloat = 50
    
    private let viewModel: MobileContentButtonViewModel
    private let buttonView: UIView = UIView()
    private let buttonTitle: UILabel = UILabel()
    private let buttonImagePaddingToButtonTitle: CGFloat = 12
    
    private var buttonImageView: UIImageView?
    private var buttonViewWidthConstraint: NSLayoutConstraint?
    
    init(viewModel: MobileContentButtonViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
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
        
        let buttonIcon: MobileContentButtonIcon? = viewModel.icon
        
        // buttonView
        buttonView.backgroundColor = viewModel.backgroundColor
        buttonView.layer.cornerRadius = 5
        
        if let borderColor = viewModel.borderColor, let borderWidth = viewModel.borderWidth {
            buttonView.layer.borderColor = borderColor.cgColor
            buttonView.layer.borderWidth = borderWidth
        }
        
        addSubview(buttonView)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.constrainTopToView(view: self)
        _ = buttonView.constrainBottomToView(view: self)
        _ = buttonView.addHeightConstraint(
            constant: MobileContentButtonView.buttonHeight,
            relatedBy: .greaterThanOrEqual,
            priority: 1000
        )
        
        buttonView.constrainCenterHorizontallyInView(view: self)
        
        let buttonViewWidth: CGFloat
        
        switch viewModel.buttonWidth {
        case .percentageOfContainer(let widthPercentageOfContainer):
            buttonViewWidth = containerWidth * widthPercentageOfContainer
        case .points(let widthPoints):
            buttonViewWidth = widthPoints
        }
        
        buttonViewWidthConstraint = buttonView.addWidthConstraint(constant: buttonViewWidth)
        
        // buttonTitle
        buttonTitle.isUserInteractionEnabled = false
        buttonTitle.backgroundColor = .clear
        buttonTitle.numberOfLines = 0
        buttonTitle.lineBreakMode = .byWordWrapping
        buttonTitle.textAlignment = .center
        buttonTitle.font = viewModel.font
        buttonTitle.text = viewModel.title
        buttonTitle.textColor = viewModel.titleColor
        
        buttonView.addSubview(buttonTitle)
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        buttonTitle.constrainTopToView(view: self)
        _ = buttonTitle.constrainBottomToView(view: self)
        
        if buttonIcon == nil {
            buttonTitle.constrainLeadingToView(view: self)
            buttonTitle.constrainTrailingToView(view: self)
        }
        else {
            buttonTitle.constrainCenterHorizontallyInView(view: self)
        }
                
        // buttonImageView
        if let buttonIcon = buttonIcon {
            
            let buttonImageView: UIImageView = UIImageView(image: buttonIcon.image)
            buttonImageView.isUserInteractionEnabled = false
            buttonImageView.backgroundColor = .clear
            
            buttonView.addSubview(buttonImageView)
            buttonImageView.translatesAutoresizingMaskIntoConstraints = false
            buttonImageView.constrainCenterVerticallyInView(view: self)
                        
            switch buttonIcon.gravity {
            
            case .start:
                
                let trailing: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .leading,
                    multiplier: 1,
                    constant: buttonImagePaddingToButtonTitle * -1
                )
                
                addConstraint(trailing)
                
            case .end:
                
                let leading: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .leading,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .trailing,
                    multiplier: 1,
                    constant: buttonImagePaddingToButtonTitle
                )
                
                addConstraint(leading)
            
            default:
                
                let trailing: NSLayoutConstraint = NSLayoutConstraint(
                    item: buttonImageView,
                    attribute: .trailing,
                    relatedBy: .equal,
                    toItem: buttonTitle,
                    attribute: .leading,
                    multiplier: 1,
                    constant: buttonImagePaddingToButtonTitle * -1
                )
                
                addConstraint(trailing)
            }
            
            _ = buttonImageView.addWidthConstraint(constant: CGFloat(buttonIcon.size))
            _ = buttonImageView.addHeightConstraint(constant: CGFloat(buttonIcon.size))
            
            self.buttonImageView = buttonImageView
        }
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
        
        switch viewModel.buttonWidth {
        case .percentageOfContainer(let value):
            buttonViewWidthConstraint?.constant = containerWidth * value
            layoutIfNeeded()
        case .points( _):
            break
        }
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
