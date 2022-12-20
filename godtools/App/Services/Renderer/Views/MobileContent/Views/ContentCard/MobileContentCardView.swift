//
//  MobileContentCardView.swift
//  godtools
//
//  Created by Levi Eggert on 1/22/22.
//  Copyright © 2022 Cru. All rights reserved.
//

import UIKit

class MobileContentCardView: MobileContentStackView {
    
    private let viewModel: MobileContentCardViewModel
    private let viewCornerRadius: CGFloat = 10
    
    private var shadowView: UIView?
    private var buttonOverlay: UIButton?
    
    init(viewModel: MobileContentCardViewModel) {
        
        self.viewModel = viewModel
        
        super.init(viewModel: viewModel, contentInsets: UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 10), itemSpacing: 0, scrollIsEnabled: false)
        
        setupLayout()
        setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var paddingInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private func setupLayout() {
        
        backgroundColor = .white
        layer.cornerRadius = viewCornerRadius
        
        drawShadow()
    }
    
    private func setupBinding() {
        
    }
}
