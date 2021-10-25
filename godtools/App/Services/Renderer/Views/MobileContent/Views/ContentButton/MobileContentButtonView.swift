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
    
    static let buttonHeight = 50
    
    private let viewModel: MobileContentButtonViewModelType
    private let button: UIButton = UIButton(type: .custom)
    
    required init(viewModel: MobileContentButtonViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        button.addTarget(self, action: #selector(handleButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // button
        addSubview(button)
        button.constrainEdgesToSuperview()
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: button,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: CGFloat(MobileContentButtonView.buttonHeight)
        )
        heightConstraint.priority = UILayoutPriority(1000)
        button.addConstraint(heightConstraint)
        
        button.layer.cornerRadius = 5
    }
    
    private func setupBinding() {
        
        button.backgroundColor = viewModel.backgroundColor
        button.titleLabel?.font = viewModel.font
        button.setTitle(viewModel.title, for: .normal)
        button.setTitleColor(viewModel.titleColor, for: .normal)
        
        if let borderColor = viewModel.borderColor, let borderWidth = viewModel.borderWidth {
            button.layer.borderColor = borderColor.cgColor
            button.layer.borderWidth = borderWidth
        }
        
        if let icon = viewModel.icon, let image = viewModel.iconImage {
            
            if icon.gravity == .end {
                button.semanticContentAttribute = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
            }
            
            button.setImage(image, for: .normal)
            
            button.setInsets(forContentPadding:
                UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6),
                imageTitlePadding: 10,
                iconGravity: icon.gravity
            )
        }
        
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
