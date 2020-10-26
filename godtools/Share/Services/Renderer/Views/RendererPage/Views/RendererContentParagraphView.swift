//
//  RendererContentParagraphView.swift
//  godtools
//
//  Created by Levi Eggert on 10/26/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class RendererContentParagraphView: UIStackView {
    
    private let viewModel: RendererContentParagraphViewModel
    
    required init(viewModel: RendererContentParagraphViewModel) {
        
        self.viewModel = viewModel
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
