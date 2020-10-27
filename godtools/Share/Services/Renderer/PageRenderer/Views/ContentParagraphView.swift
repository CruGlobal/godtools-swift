//
//  ContentParagraphView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ContentParagraphView: RendererNodeView {
    
    private let stackView: UIStackView = UIStackView()
    
    let viewModel: ContentParagraphViewModel
    
    required init(viewModel: ContentParagraphViewModel) {
        
        self.viewModel = viewModel
        
        stackView.axis = .vertical
    }
    
    var contentView: UIView {
        return stackView
    }
}
