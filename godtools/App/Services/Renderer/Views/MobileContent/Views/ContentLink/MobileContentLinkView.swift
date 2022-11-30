//
//  MobileContentLinkView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentLinkView: MobileContentView {
    
    private let viewModel: MobileContentLinkViewModelType
    private let linkButton: UIButton = UIButton(type: .custom)
    
    required init(viewModel: MobileContentLinkViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
        
        linkButton.addTarget(self, action: #selector(handleLinkTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        // linkButton
        let parentView: UIView = self
        parentView.addSubview(linkButton)
        linkButton.translatesAutoresizingMaskIntoConstraints = false
        linkButton.constrainEdgesToView(view: parentView)
        
        let heightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: linkButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 50
        )
        heightConstraint.priority = UILayoutPriority(1000)
        linkButton.addConstraint(heightConstraint)
        
        linkButton.layer.cornerRadius = 5
    }
    
    private func setupBinding() {
        
        linkButton.backgroundColor = viewModel.backgroundColor
        linkButton.titleLabel?.font = viewModel.font
        linkButton.setTitle(viewModel.title, for: .normal)
        linkButton.setTitleColor(viewModel.titleColor, for: .normal)
    }
    
    @objc func handleLinkTapped() {
        
        viewModel.linkTapped()
        
        super.sendEventsToAllViews(eventIds: viewModel.linkEvents, rendererState: viewModel.rendererState)
        
        if let clickableUrl = viewModel.getClickableUrl() {
            super.sendButtonWithUrlEventToRootView(url: clickableUrl)
        }
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
