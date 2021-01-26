//
//  ToolPageModalView.swift
//  godtools
//
//  Created by Levi Eggert on 11/9/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolPageModalView: UIView {
    
    private let viewModel: ToolPageModalViewModelType
        
    @IBOutlet weak private var contentContainerView: UIView!
    
    required init(viewModel: ToolPageModalViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("x deinit: \(type(of: self))")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: ToolPageModalView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.backgroundColor = .clear
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToSuperview()
        }
    }
    
    private func setupLayout() {
        
    }
    
    private func setupBinding() {
        
        backgroundColor = viewModel.backgroundColor
        
        viewModel.contentView.addObserver(self) { [weak self] (contentView: MobileContentStackView?) in
            if let contentView = contentView {
                self?.addContentView(contentView: contentView)
            }
        }
    }
    
    private func addContentView(contentView: MobileContentStackView) {
        
        let contentParentView: UIView = contentContainerView
        
        contentParentView.addSubview(contentView)
        
        contentView.constrainEdgesToSuperview()
        layoutIfNeeded()
        
        let modalContentSize: CGSize = contentView.contentSize
        let shouldCenterVertically: Bool = modalContentSize.height < frame.size.height
        
        if shouldCenterVertically {
            let difference: CGFloat = frame.size.height - modalContentSize.height
            contentView.setContentInset(contentInset: UIEdgeInsets(top: difference / 2, left: 0, bottom: 0, right: 0))
        }
    }
}
