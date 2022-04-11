//
//  MobileContentHeaderView.swift
//  godtools
//
//  Created by Levi Eggert on 4/20/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentHeaderView: MobileContentView {
    
    private let viewModel: MobileContentHeaderViewModelType
    
    private var textView: MobileContentTextView?
    
    required init(viewModel: MobileContentHeaderViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
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
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        if let textView = childView as? MobileContentTextView {
            addTextView(textView: textView)
        }
    }
    
    override var heightConstraintType: MobileContentViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Text View

extension MobileContentHeaderView {
    
    private func addTextView(textView: MobileContentTextView) {
        
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
