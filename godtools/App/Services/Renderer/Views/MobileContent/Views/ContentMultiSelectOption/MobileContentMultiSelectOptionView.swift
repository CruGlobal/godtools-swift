//
//  MobileContentMultiSelectOptionView.swift
//  godtools
//
//  Created by Levi Eggert on 9/8/21.
//  Copyright © 2021 Cru. All rights reserved.
//

import UIKit

class MobileContentMultiSelectOptionView: MobileContentView {
    
    private let viewModel: MobileContentMultiSelectOptionViewModelType
    private let viewCornerRadius: CGFloat = 10
    
    private var textView: MobileContentTextView?
        
    @IBOutlet weak private var shadowView: UIView!
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var textContainerView: UIView!
        
    required init(viewModel: MobileContentMultiSelectOptionViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentMultiSelectOptionView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
            rootNibView.backgroundColor = .clear
            backgroundColor = .clear
        }
    }
    
    private func setupLayout() {
                
        // shadowView
        shadowView.layer.cornerRadius = viewCornerRadius
        shadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOpacity = 0.3
        shadowView.clipsToBounds = false
        
        // contentView
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = viewCornerRadius
        contentView.clipsToBounds = true
    }
    
    override func renderChild(childView: MobileContentView) {
        
        super.renderChild(childView: childView)
        
        if let textView = childView as? MobileContentTextView {
            addTextView(textView: textView)
        }
    }
    
    override var contentStackHeightConstraintType: MobileContentStackChildViewHeightConstraintType {
        return .constrainedToChildren
    }
}

// MARK: - Text

extension MobileContentMultiSelectOptionView {
    
    private func addTextView(textView: MobileContentTextView) {
        
        guard self.textView == nil else {
            return
        }
        
        textContainerView.addSubview(textView)
        textView.constrainEdgesToSuperview(edgeInsets: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        self.textView = textView
    }
}
