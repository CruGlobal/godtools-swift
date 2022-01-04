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
    
    private static let buttonHeight = 50
    
    private let viewModel: MobileContentButtonViewModelType
    private let buttonTitle: UILabel = UILabel()
    private let buttonImagePaddingToButtonTitle: CGFloat = 12
    
    private var tapGesture: UITapGestureRecognizer?
    private var buttonImageView: UIImageView?
    
    required init(viewModel: MobileContentButtonViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        // tapGesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
        addGestureRecognizer(tapGesture)
        self.tapGesture = tapGesture
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        layer.cornerRadius = 5
        
        // buttonTitle
        buttonTitle.isUserInteractionEnabled = false
        buttonTitle.backgroundColor = .clear
        buttonTitle.numberOfLines = 0
        buttonTitle.lineBreakMode = .byWordWrapping
        buttonTitle.textAlignment = .center
        buttonTitle.font = viewModel.font
        buttonTitle.text = viewModel.title
        buttonTitle.textColor = viewModel.titleColor
        
        addButtonTitleAndConstraints(buttonTitle: buttonTitle, buttonIcon: viewModel.icon)
        
        // buttonImageView
        if let buttonIcon = viewModel.icon {
            
            let buttonImageView: UIImageView = UIImageView(image: buttonIcon.image)
            buttonImageView.isUserInteractionEnabled = false
            buttonImageView.backgroundColor = .clear
            
            addButtonImageViewAndConstraints(buttonImageView: buttonImageView, buttonIcon: buttonIcon)
            
            self.buttonImageView = buttonImageView
        }
    }
    
    private func setupBinding() {
        
        backgroundColor = viewModel.backgroundColor
        
        if let borderColor = viewModel.borderColor, let borderWidth = viewModel.borderWidth {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = borderWidth
        }
        
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
    
    @objc private func buttonTapped() {
        
        switch viewModel.buttonType {
        
        case .event:
            super.sendEventsToAllViews(eventIds: viewModel.buttonEvents, rendererState: viewModel.rendererState)
        
        case .url:
            super.sendButtonWithUrlEventToRootView(url: viewModel.buttonUrl)
       
        case .unknown:
            break
        }
        
        viewModel.buttonTapped()
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Constraints

extension MobileContentButtonView {

    private func addButtonTitleAndConstraints(buttonTitle: UILabel, buttonIcon: MobileContentButtonIcon?) {
        
        addSubview(buttonTitle)
        
        buttonTitle.translatesAutoresizingMaskIntoConstraints = false
        
        buttonTitle.constrainTopToView(view: self)
        
        buttonTitle.constrainBottomToView(view: self)
        
        if buttonIcon != nil {
            
            buttonTitle.constrainCenterHorizontallyInView(view: self)
        }
        else {
            
            buttonTitle.constrainLeadingToView(view: self)
            
            buttonTitle.constrainTrailingToView(view: self)
        }
        
        buttonTitle.addHeightConstraint(
            constant: CGFloat(MobileContentButtonView.buttonHeight),
            relatedBy: .greaterThanOrEqual,
            priority: 1000
        )
    }
    
    private func addButtonImageViewAndConstraints(buttonImageView: UIImageView, buttonIcon: MobileContentButtonIcon) {
        
        addSubview(buttonImageView)
        
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
        }
        
        buttonImageView.addWidthConstraint(constant: CGFloat(buttonIcon.size))
        
        buttonImageView.addHeightConstraint(constant: CGFloat(buttonIcon.size))
    }
}
