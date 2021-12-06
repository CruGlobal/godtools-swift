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
    
    private var buttonImageView: UIImageView?
    
    required init(viewModel: MobileContentButtonViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        //button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        layer.cornerRadius = 5
        
        // buttonTitle
        addButtonTitleAndConstraints(buttonTitle: buttonTitle, buttonIcon: viewModel.icon)
        
        buttonTitle.numberOfLines = 0
        buttonTitle.lineBreakMode = .byWordWrapping
        buttonTitle.textAlignment = .center
        
        // buttonImageView
        if let buttonIcon = viewModel.icon {
            
            let buttonImageView: UIImageView = UIImageView(image: buttonIcon.image)
            
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
        
        buttonTitle.font = viewModel.font
        buttonTitle.text = viewModel.title
        buttonTitle.textColor = viewModel.titleColor
    
        viewModel.visibilityState.addObserver(self) { [weak self] (visibilityState: MobileContentViewVisibilityState) in
            self?.setVisibilityState(visibilityState: visibilityState)
        }
    }
    
    @objc func handleButtonTapped() {
        
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
