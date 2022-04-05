//
//  MobileContentCardCollectionPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardCollectionPageCardView: MobileContentView, NibBased {
    
    private let viewModel: MobileContentCardCollectionPageCardViewModelType
    
    private var contentStackView: MobileContentStackView?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var pageNumberLabel: UILabel!
    
    required init(viewModel: MobileContentCardCollectionPageCardViewModelType) {
        
        self.viewModel = viewModel
        
        super.init(frame: UIScreen.main.bounds)
        
        loadNib()
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
        
        pageNumberLabel.text = viewModel.pageNumber
    }
    
    override func renderChild(childView: MobileContentView) {
        super.renderChild(childView: childView)
                
        if let contentStackView = childView as? MobileContentStackView {
            addContentStackView(contentStackView: contentStackView)
        }
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
