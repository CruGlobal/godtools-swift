//
//  MobileContentNumberView.swift
//  godtools
//
//  Created by Levi Eggert on 3/25/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import Foundation

class MobileContentNumberView: MobileContentView {
    
    private let viewModel: MobileContentNumberViewModelType
    
    private var textView: MobileContentTextView?
    
    required init(viewModel: MobileContentNumberViewModelType) {
        
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
    
    func removeTextViewTextLabel() -> UILabel? {
        return textView?.removeTextLabel()
    }
    
    // MARK: - MobileContentView
    
    override func renderChild(childView: MobileContentView) {
        
        if let textView = childView as? MobileContentTextView {
            addTextView(textView: textView)
        }
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Text View

extension MobileContentNumberView {
    
    private func addTextView(textView: MobileContentTextView) {
        
        guard self.textView == nil else {
            return
        }
        
        addSubview(textView)
        textView.constrainEdgesToSuperview()
        self.textView = textView
        
        let scaledFont: UIFont = textView.viewModel.getScaledFont(
            fontSizeToScale: viewModel.fontSize,
            fontWeightElseUseTextDefault: viewModel.fontWeight
        )
                        
        textView.getTextLabel().numberOfLines = 1
        textView.getTextLabel().text = viewModel.text
        textView.getTextLabel().font = scaledFont
        textView.getTextLabel().textColor = viewModel.textColor
        textView.getTextLabel().textAlignment = viewModel.textAlignment
    }
}
