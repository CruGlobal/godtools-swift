//
//  MobileContentButtonView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

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
        
        if viewModel.iconImage != nil {
            
            let iconSize = Int(viewModel.iconSize)
            
            let imageSize = CGSize(width: iconSize, height: iconSize)
            
            button.imageEdgeInsets = UIEdgeInsets(
                top: (button.frame.size.height - imageSize.height) / 2,
                left: (button.frame.size.width - imageSize.width) / 2,
                bottom: (button.frame.size.height - imageSize.height) / 2,
                right: 10
            )
        }
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
        
        if let iconImage = viewModel.iconImage {
            button.setImage(iconImage, for: .normal)
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
