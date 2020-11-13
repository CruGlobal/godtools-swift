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
    
    private var tipContentStackView: ToolPageContentStackView?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tipContentStackView?.removeFromSuperview()
    }
    
    func configure(viewModel: ToolPageContentStackViewModel) {
                
        let tipContentStackView = ToolPageContentStackView(viewModel: viewModel)
        contentView.addSubview(tipContentStackView)
        tipContentStackView.constrainEdgesToSuperview()
                
        self.tipContentStackView = tipContentStackView
    }
}
