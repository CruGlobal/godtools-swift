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
    
    private var tipContentStackView: MobileContentStackView?
    
    @IBOutlet weak private var contentStackContainerView: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tipContentStackView?.removeFromSuperview()
    }
    
    func configure(viewModel: ToolPageContentStackViewModel) {
                
        let tipContentStackView = MobileContentStackView(viewModel: viewModel, itemSpacing: 15, scrollIsEnabled: true)
        contentStackContainerView.addSubview(tipContentStackView)
        tipContentStackView.constrainEdgesToSuperview()
                
        self.tipContentStackView = tipContentStackView
    }
}
