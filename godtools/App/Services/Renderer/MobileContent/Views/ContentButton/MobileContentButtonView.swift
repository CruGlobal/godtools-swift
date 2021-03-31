//
//  MobileContentButtonView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentButtonView: MobileContentView {
    
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
            constant: 50
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
    }
    
    @objc func handleButtonTapped() {
        
        switch viewModel.buttonType {
        
        case .event:
            super.sendEventsToAllViews(events: viewModel.buttonEvents)
        
        case .url:
            super.sendButtonWithUrlEventToRootView(url: viewModel.buttonUrl)
       
        case .unknown:
            break
        }
        
        viewModel.buttonTapped()
    }
    
    // MARK: - MobileContentView
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
