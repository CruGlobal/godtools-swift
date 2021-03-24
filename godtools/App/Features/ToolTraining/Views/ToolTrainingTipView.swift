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
    @IBOutlet weak private var bottomGradientView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // bottom gradient
        bottomGradientView.isUserInteractionEnabled = false
        bottomGradientView.backgroundColor = .clear
        let bottomGradient = CAGradientLayer()
        bottomGradient.frame = bottomGradientView.bounds
        bottomGradient.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.5).cgColor,
            UIColor.white.withAlphaComponent(0.75).cgColor,
            UIColor.white.cgColor
        ]
        bottomGradientView.layer.insertSublayer(bottomGradient, at: 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        tipContentStackView?.removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tipContentStackView?.setContentInset(contentInset: UIEdgeInsets(top: 0, left: 0, bottom: bottomGradientView.frame.size.height, right: 0))
    }
    
    // TODO: Fix this for new renderer changes. ~Levi
    /*
    func configure(viewModel: ToolPageContentStackContainerViewModel) {
            
        let tipContentStackView = MobileContentStackView(viewRenderer: viewModel.contentStackRenderer, itemSpacing: 15, scrollIsEnabled: true)
        contentStackContainerView.addSubview(tipContentStackView)
        tipContentStackView.constrainEdgesToSuperview()
                
        self.tipContentStackView = tipContentStackView
    }*/
}
