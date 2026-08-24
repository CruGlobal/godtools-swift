//
//  LegacyMobileContentHeadingView.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class LegacyMobileContentHeadingView: LegacyMobileContentView {
    
    private let viewModel: MobileContentHeadingViewModel
    
    private var textView: LegacyMobileContentTextView?
    
    init(viewModel: MobileContentHeadingViewModel) {
        
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

extension LegacyMobileContentHeadingView {
    
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
                
        textView.getTextLabel().font = scaledFont
        textView.getTextLabel().textColor = viewModel.textColor
    }
}
