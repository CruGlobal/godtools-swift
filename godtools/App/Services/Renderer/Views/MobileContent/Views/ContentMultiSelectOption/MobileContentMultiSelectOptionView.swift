//
//  MobileContentMultiSelectOptionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectOptionView: MobileContentStackView {
    
    private let viewModel: MobileContentMultiSelectOptionViewModelType
    private let viewCornerRadius: CGFloat = 10
    
    private let shadowView: UIView = UIView()
    private let contentView: UIView = UIView()
    private let overlayButton: UIButton = UIButton(type: .custom)
                    
    required init(viewModel: MobileContentMultiSelectOptionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(itemHorizontalInsets: 0, itemSpacing: 10, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
        
        overlayButton.addTarget(self, action: #selector(overlayButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required init(itemHorizontalInsets: CGFloat, itemSpacing: CGFloat, scrollIsEnabled: Bool) {
        fatalError("init(itemHorizontalInsets:itemSpacing:scrollIsEnabled:) has not been implemented")
    }
    
    private func setupLayout() {
              
        // shadowView
        insertSubview(shadowView, at: 0)
        shadowView.constrainEdgesToSuperview()
        shadowView.layer.cornerRadius = viewCornerRadius
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.clipsToBounds = false
        
        // contentView
        getContentView().addSubview(contentView)
        contentView.constrainEdgesToSuperview()
        contentView.layer.cornerRadius = viewCornerRadius
    }
    
    private func setupBinding() {
        
        viewModel.backgroundColor.addObserver(self) { [weak self] (backgroundColor: UIColor) in
            self?.contentView.backgroundColor = backgroundColor
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
        
        // overlay button
        addSubview(overlayButton)
        overlayButton.constrainEdgesToSuperview()
        overlayButton.setTitle(nil, for: .normal)
        overlayButton.backgroundColor = .clear
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}
