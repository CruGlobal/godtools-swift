//
//  LegacyMobileContentCardCollectionPageCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/26/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class LegacyMobileContentCardCollectionPageCardView: LegacyMobileContentView, NibBased {
    
    private let viewModel: MobileContentCardCollectionPageCardViewModel
    
    private var contentStackView: LegacyMobileContentStackView?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    @IBOutlet weak private var pageNumberLabel: UILabel!
    
    init(viewModel: MobileContentCardCollectionPageCardViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, frame: UIScreen.main.bounds)
        
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
    
    override func renderChild(childView: LegacyMobileContentView) {
        super.renderChild(childView: childView)
                
        if let contentStackView = childView as? LegacyMobileContentStackView {
            addContentStackView(contentStackView: contentStackView)
        }
    }
}

// MARK: - Content Stack

extension LegacyMobileContentCardCollectionPageCardView {
    
    func addContentStackView(contentStackView: LegacyMobileContentStackView) {
        
        guard self.contentStackView == nil else {
            return
        }
        
        contentStackContainerView.addSubview(contentStackView)
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constrainEdgesToView(view: contentStackContainerView)
                
        self.contentStackView = contentStackView
    }
}
