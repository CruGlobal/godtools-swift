//
//  MobileContentMultiSelectOptionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectOptionView: MobileContentStackView {
    
    private let viewModel: MobileContentMultiSelectOptionViewModel
    
    private let shadowView: UIView = UIView()
    private let overlayButton: UIButton = UIButton(type: .custom)
                    
    init(viewModel: MobileContentMultiSelectOptionViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12), itemSpacing: 10, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
        
        overlayButton.addTarget(self, action: #selector(overlayButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
                        
        layer.cornerRadius = 10
    }
    
    private func setupBinding() {
        
        viewModel.backgroundColor.addObserver(self) { [weak self] (backgroundColor: UIColor) in
            self?.backgroundColor = backgroundColor
        }
        
        if !viewModel.hidesShadow {
            drawShadow()
        }
    }
    
    @objc func overlayButtonTapped() {
        viewModel.multiSelectOptionTapped()
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        childView.backgroundColor = .clear
    }
    
    override func finishedRenderingChildren() {
        
        super.finishedRenderingChildren()
        
        if !subviews.contains(overlayButton) {
            
            let parentView: UIView = self
            parentView.addSubview(overlayButton)
            overlayButton.translatesAutoresizingMaskIntoConstraints = false
            overlayButton.constrainEdgesToView(view: parentView)
            overlayButton.setTitle(nil, for: .normal)
            overlayButton.backgroundColor = .clear
        }
        
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}
