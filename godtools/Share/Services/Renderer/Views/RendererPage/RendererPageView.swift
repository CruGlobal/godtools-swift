//
//  RendererPageView.swift
//  godtools
//
//  Created by Levi Eggert on 10/23/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class RendererPageView: UIView {
    
    private let viewModel: RendererPageViewModelType
    
    private var scrollView: UIScrollView = UIScrollView()
    
    required init(viewModel: RendererPageViewModelType, frame: CGRect) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        drawBorder(color: .red)
        scrollView.drawBorder(color: .blue)
    }
}
