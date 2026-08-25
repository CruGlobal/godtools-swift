//
//  LegacyMobileContentHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LegacyMobileContentHeaderView: LegacyMobileContentView {
    
    private let viewModel: LegacyMobileContentHeaderViewModel
    
    private var textView: LegacyMobileContentTextView?
    
    init(viewModel: LegacyMobileContentHeaderViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        
        backgroundColor = .clear
    }
    
    private func setupBinding() {
        
    }
    
    // MARK: - LegacyMobileContentView
    
    override func renderChild(childView: LegacyMobileContentView) {
        
        if let textView = childView as? LegacyMobileContentTextView {
            addTextView(textView: textView)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Text View

extension LegacyMobileContentHeaderView {
    
    private func addTextView(textView: LegacyMobileContentTextView) {
        
        guard self.textView == nil else {
            return
        }
        
        let parentView: UIView = self
        parentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.constrainEdgesToView(view: parentView)
        self.textView = textView
        
        let scaledFont: UIFont = textView.viewModel.getScaledFont(
            fontSizeToScale: viewModel.fontSize,
            fontWeightElseUseTextDefault: viewModel.fontWeight
        )
                        
        textView.getTextLabel().numberOfLines = 0
        textView.getTextLabel().lineBreakMode = .byWordWrapping
        textView.getTextLabel().font = scaledFont
    }
}
