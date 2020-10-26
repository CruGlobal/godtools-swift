//
//  ToolTrainingTipView.swift
//  godtools
//
//  Created by Levi Eggert on 10/22/20.
//  Copyright © 2020 Cru. All rights reserved.
//

import UIKit

class ToolTrainingTipView: UICollectionViewCell {
    
    static let nibName: String = "ToolTrainingTipView"
    static let reuseIdentifier: String = "ToolTrainingTipViewReuseIdentifier"
    
    private var viewModel: RendererPageViewModelType?
    private var page: RendererPageView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        page?.removeFromSuperview()
        page = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        page?.frame = contentView.bounds
    }
    
    func configure(viewModel: RendererPageViewModelType) {
        
        self.viewModel = viewModel
        
        let page: RendererPageView = RendererPageView(
            viewModel: viewModel,
            frame: contentView.bounds
        )
        
        contentView.addSubview(page)
    }
}
