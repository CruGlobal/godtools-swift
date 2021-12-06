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
        
        drawBorder(color: .green)
        buttonTitle.drawBorder(color: .blue)
        buttonImageView?.drawBorder(color: .red)
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
        
        // top
        let top: NSLayoutConstraint = NSLayoutConstraint(
            item: buttonTitle,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(top)
        
        // bottom
        let bottom: NSLayoutConstraint = NSLayoutConstraint(
            item: buttonTitle,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(bottom)
        
        if buttonIcon != nil {
            
            let centerHorizontally: NSLayoutConstraint = NSLayoutConstraint(
                item: buttonTitle,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
            
            addConstraint(centerHorizontally)
        }
        else {
            
            let leading: NSLayoutConstraint = NSLayoutConstraint(
                item: buttonTitle,
                attribute: .leading,
                relatedBy: .equal,
                toItem: self,
                attribute: .leading,
                multiplier: 1,
                constant: 0
            )
            
            addConstraint(leading)
            
            let trailing: NSLayoutConstraint = NSLayoutConstraint(
                item: buttonTitle,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self,
                attribute: .trailing,
                multiplier: 1,
                constant: 0
            )
            
            addConstraint(trailing)
        }
        
        // height
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: buttonTitle,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: CGFloat(MobileContentButtonView.buttonHeight)
        )
        heightConstraint.priority = UILayoutPriority(1000)
        buttonTitle.addConstraint(heightConstraint)
    }
    
    private func addButtonImageViewAndConstraints(buttonImageView: UIImageView, buttonIcon: MobileContentButtonIcon) {
        
        addSubview(buttonImageView)
        
        buttonImageView.translatesAutoresizingMaskIntoConstraints = false
               
        let centerVertically: NSLayoutConstraint = NSLayoutConstraint(
            item: buttonImageView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        )
        
        addConstraint(centerVertically)
                
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
            
            addConstraint(trailing)
            
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
            
            addConstraint(leading)
        }
        
        buttonImageView.addWidthConstraint(constant: CGFloat(buttonIcon.size))
        buttonImageView.addHeightConstraint(constant: CGFloat(buttonIcon.size))
    }
}
