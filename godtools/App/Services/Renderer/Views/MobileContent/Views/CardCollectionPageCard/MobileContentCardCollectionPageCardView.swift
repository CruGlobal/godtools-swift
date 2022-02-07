//
//  MobileContentCardCollectionPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageCardView: MobileContentView {
    
    private let viewModel: MobileContentCardCollectionPageCardViewModelType
    
    private var contentStackView: MobileContentStackView?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var pageNumberLabel: UILabel!
    
    required init(viewModel: MobileContentCardCollectionPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        initializeNib()
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNib() {
        
        let nib: UINib = UINib(nibName: String(describing: MobileContentCardCollectionPageCardView.self), bundle: nil)
        let contents: [Any]? = nib.instantiate(withOwner: self, options: nil)
        if let rootNibView = (contents as? [UIView])?.first {
            addSubview(rootNibView)
            rootNibView.frame = bounds
            rootNibView.translatesAutoresizingMaskIntoConstraints = false
            rootNibView.constrainEdgesToView(view: self)
            rootNibView.backgroundColor = .clear
            backgroundColor = .clear
        }
    }
    
    private func setupLayout() {
                
    }
    
    private func setupBinding() {
        
        pageNumberLabel.text = viewModel.pageNumber
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
                
        if let contentStackView = childView as? MobileContentStackView {
            addContentStackView(contentStackView: contentStackView)
        }
    }
    
    override func finishedRenderingChildren() {
        super.finishedRenderingChildren()
    }
}

// MARK: - Content Stack

extension MobileContentCardCollectionPageCardView {
    
    func addContentStackView(contentStackView: MobileContentStackView) {
        
        guard self.contentStackView == nil else {
            return
        }
        
        contentStackContainerView.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: contentStackContainerView)
                
        self.contentStackView = contentStackView
    }
}
