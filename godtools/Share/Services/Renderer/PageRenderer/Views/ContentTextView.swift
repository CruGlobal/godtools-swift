//
//  ContentTextView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContentTextView: RendererNodeView {
    
    private let label: UILabel = UILabel()
    
    let viewModel: ContentTextViewModel
    
    required init(viewModel: ContentTextViewModel) {
        
        self.viewModel = viewModel
        
        setupLayout()
        setupBinding()
    }
    
    private func setupLayout() {
        
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = UIColor.black
        label.text = viewModel.text
        label.sizeToFit()
    }
    
    private func setupBinding() {
        
    }
    
    var contentView: UIView {
        return label
    }
}
