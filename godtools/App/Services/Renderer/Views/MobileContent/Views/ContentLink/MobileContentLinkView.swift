//
//  MobileContentLinkView.swift
//  godtools
//
//  Created by Levi Eggert on 3/10/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentLinkView: MobileContentView {
    
    private let viewModel: MobileContentLinkViewModel
    private let backgroundView: UIView = UIView(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    
    required init(viewModel: MobileContentLinkViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        let parentView: UIView = self
        
        // backgroundView
        parentView.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.constrainEdgesToView(view: parentView)
        
        let backgroundViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(
            item: backgroundView,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 50
        )
        backgroundViewHeightConstraint.priority = UILayoutPriority(1000)
        backgroundView.addConstraint(backgroundViewHeightConstraint)
        
        backgroundView.layer.cornerRadius = 5
        
        // titleLabel
        parentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.constrainEdgesToView(view: parentView)
        titleLabel.backgroundColor = .clear
        titleLabel.textAlignment = .center
    }
    
    private func setupBinding() {
        
        backgroundView.backgroundColor = viewModel.backgroundColor
        titleLabel.font = viewModel.font
        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleColor
    }
    
    // MARK: - MobileContentView
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
