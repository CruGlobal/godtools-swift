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
    
    private var toolPage: ToolPageView?
    private var viewModel: ToolPageViewModel?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        viewModel = nil
        toolPage = nil
    }
    
    func configure(viewModel: ToolPageViewModel) {
        
        let toolPage: ToolPageView = ToolPageView(viewModel: viewModel)
        
        contentView.addSubview(toolPage.view)
        toolPage.view.constrainEdgesToSuperview()
        
        self.toolPage = toolPage
        self.viewModel = viewModel
    }
}
