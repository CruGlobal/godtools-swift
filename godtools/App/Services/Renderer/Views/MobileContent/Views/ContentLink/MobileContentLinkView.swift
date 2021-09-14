//
//  MobileContentLinkView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

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
        addSubview(linkButton)
        linkButton.constrainEdgesToSuperview()
        
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
    }
    
    // MARK: - MobileContentView
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
